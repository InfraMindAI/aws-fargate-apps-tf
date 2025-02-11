[
    {
        "name": "${container_name}",
        "image": "${image}",
        "cpu": ${cpu},
        "memory": ${memory},
        "portMappings": ${jsonencode([
           for port in container_ports : {
             hostPort = port
             protocol = "tcp"
             containerPort = port
           }
        ])},
        "essential": true,
        "environment": [
          {
            "name": "AWS_DEFAULT_REGION",
            "value": "${aws_region}"
          },
          {
            "name": "ENVIRONMENT",
            "value": "${cluster_name}"
          }
        ],
        "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${awslogs_group}",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "${container_name}"
          }
        }
    }
]