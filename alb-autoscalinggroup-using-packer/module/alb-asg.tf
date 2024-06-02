# Security Group for ALB
resource "aws_security_group" "allow_tls" {
  name        = var.sg_name
  description = var.sg_description
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.cidr_blocks
  }
  
  ingress {
    protocol   = "tcp"
    cidr_blocks = var.cidr_blocks
    from_port  = 80
    to_port    = 80
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-sg"
  }
}

#S3 Bucket to capture ALB access logs
resource "aws_s3_bucket" "bucket" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = var.access_log_bucket
  
  force_destroy = true

  tags = {
    Environment = var.env
  }
}

#S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = aws_s3_bucket.bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

#Apply Bucket Policy to S3 Bucket
resource "aws_s3_bucket_policy" "bucket_policy" {
  count = var.s3_bucket_exists == false ? 1 : 0
  bucket = aws_s3_bucket.bucket[0].id
  policy = file("bucket-policy.json")
  
  depends_on = [aws_s3_bucket_server_side_encryption_configuration.bucket_encryption]
}

# Application LoadBalancer
resource "aws_lb" "application-loadbalancer" {
  name               = var.alb_name
  internal           = var.internal_external
  load_balancer_type = var.loadbalancer_type
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = aws_subnet.public_subnet[*].id

  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.access_log_bucket
    prefix  = var.prefix
    enabled = true
  }

  tags = {
    Environment = var.env
  }
  depends_on = [ aws_security_group.allow_tls ]
}

# Target Group for ALB
resource "aws_lb_target_group" "autoscale_alb_tg" {
  name        = var.alb_tg_name
  target_type = var.target_type
  port        = var.instance_port 
  protocol    = var.instance_protocol
  vpc_id      = aws_vpc.test_vpc.id
  health_check {
    enabled = true
    healthy_threshold = var.healthy_threshold
    interval = var.interval
    path = var.healthcheck_path
    port = "traffic-port"
    protocol = var.healthcheck_protocol
    timeout = var.timeout
    unhealthy_threshold = var.unhealthy_threshold 
  }
  depends_on = [ aws_lb.application-loadbalancer ]

  tags = {
    Environment = var.env
  }
}

# HTTP Listener for ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application-loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    target_group_arn = aws_lb_target_group.autoscale_alb_tg.arn
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

}

# HTTPS Listener for ALB
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.application-loadbalancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.autoscale_alb_tg.arn
  }

}

# Launch Configuration for ASG
#resource "aws_launch_configuration" "asg_lc" {
#  name   = var.launchconfiguration_name
#  image_id      = var.AMI_ID
#  instance_type = var.instance_type
#  iam_instance_profile = var.iam_instance_profile
#  key_name = var.key_name
#  security_groups = var.security_groups
#  associate_public_ip_address = var.associate_public_ip_address
#  enable_monitoring = var.enable_monitoring
#  ebs_optimized = var.ebs_optimized
#  root_block_device {
#    volume_type = "gp2"
#    volume_size = 10
#    delete_on_termination = true
#    encrypted = true
#  }
#  user_data = <<-EOF
#              #!/bin/bash
#              yum update -y
#              yum install -y httpd
#              service httpd start
#              chkconfig httpd on
#              echo "<h1>Deployed Via Terraform</h1>" >> /var/www/html/index.html
#              EOF
  
#  placement_tenancy = var.placement_tenancy

#  lifecycle {
#    create_before_destroy = true
#  }
#}

# Launch Template for ASG
resource "aws_launch_template" "launch_template_asg" {
  image_id               = var.AMI_ID         
  instance_type          = var.instance_type
  name                   = var.launch_template_name
  key_name               = var.key_name
  ebs_optimized = var.ebs_optimized
#  update_default_version = true

  monitoring {
    enabled = var.enable_monitoring
  }
  
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = [aws_security_group.all_traffic.id]
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  placement {
    tenancy = var.placement_tenancy
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 10
      volume_type = "gp2"
      encrypted = true
      kms_key_id = var.kms_key_id     ### Provide the kms_key_id for your AWS Account.
      delete_on_termination = true
    }
  }
 
  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = var.env       
    }
  }
  
  tag_specifications {
     resource_type = "volume"
     tags = {
       Environment = var.env    
    }
  } 

  user_data = filebase64("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_lb.application-loadbalancer, aws_lb_target_group.autoscale_alb_tg]
}

# AutoScaling Group
resource "aws_autoscaling_group" "asg" {
  name                 = var.asg_name
#  launch_configuration = aws_launch_configuration.asg_lc.name
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity  
  vpc_zone_identifier  = aws_subnet.public_subnet[*].id
  default_cooldown     = var.default_cooldown  # The amount of time, in seconds, after a scaling activity completes before another scaling activity can start.
  service_linked_role_arn = var.service_linked_role_arn
  health_check_grace_period = var.health_check_grace_period   # Time (in seconds) after instance comes into service before checking health.
  health_check_type    = var.health_check_type
  force_delete         = var.force_delete # Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate.
  target_group_arns    = [aws_lb_target_group.autoscale_alb_tg.arn]
  termination_policies = ["OldestLaunchTemplate"]               ### ["OldestLaunchConfiguration"]
  
  launch_template {
    id      = aws_launch_template.launch_template_asg.id
    version = "$Latest"
  }

  tag {
          key                 = "Environment"
          value               = var.env
          propagate_at_launch = true
  }
  

  lifecycle {
    create_before_destroy = true
  }
 
  depends_on = [ aws_launch_template.launch_template_asg ]    ### [ aws_launch_configuration.asg_lc ]
}

# AutoScaling Policy for Scale UP
resource "aws_autoscaling_policy" "scaleup" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name                   = "scaleout"
  policy_type            = "StepScaling"
#  cooldown               = 100  # The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start, used for SimpleScaling.
  adjustment_type        = "ChangeInCapacity" 
  estimated_instance_warmup = 100  # The estimated time, in seconds, until a newly launched instance will contribute CloudWatch metrics. 

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = ""   # Without a value, AWS will treat this bound as infinity.
  }
  
  depends_on = [aws_launch_template.launch_template_asg, aws_autoscaling_group.asg]    ###[ aws_launch_configuration.asg_lc, aws_autoscaling_group.asg ]

}

# AutoScaling Policy for Scale Down
resource "aws_autoscaling_policy" "scaledown" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name                   = "scalein"
  policy_type            = "StepScaling"
#  cooldown               = 100  # The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start, used for SimpleScaling.
  adjustment_type        = "ChangeInCapacity"
  estimated_instance_warmup = 100  # The estimated time, in seconds, until a newly launched instance will contribute CloudWatch metrics.

  step_adjustment {
    scaling_adjustment          = -1
    metric_interval_lower_bound = "" # Without a value, AWS will treat this bound as infinity.
    metric_interval_upper_bound = 0  # Without a value, AWS will treat this bound as infinity.
  }
  
  depends_on = [aws_launch_template.launch_template_asg, aws_autoscaling_group.asg]    ###[ aws_launch_configuration.asg_lc, aws_autoscaling_group.asg ]

}

# Cloudwatch Alarms
resource "aws_cloudwatch_metric_alarm" "cloudwatchalarm_high" {
  alarm_name          = "CloudwatchAlarm-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors autoscaling ec2 scaleup cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scaleup.arn, var.topic_arn]
  depends_on = [ aws_autoscaling_policy.scaleup ]

  tags = {
    Environment = var.env
  }
}


resource "aws_cloudwatch_metric_alarm" "cloudwatchalarm_low" {
  alarm_name          = "CloudwatchAlarm-Low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "50"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }

  alarm_description = "This metric monitors autoscaling ec2 scaledown cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scaledown.arn, var.topic_arn]
  depends_on = [ aws_autoscaling_policy.scaledown ]

  tags = {
    Environment = var.env
  }
}
