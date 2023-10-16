# lightsail-proxy

AWS charges ~ $100/TB for data egress from most services.

... except Lightsail, which includes 2 TBs of egress ($200 value) in the already discounted $5/mo for a t3.micro (2vcpu, 1gb)

My primary use case for this right now is log / metric aggregation. I prefer NewRelic's 100GB + free queries over CloudWatch's 5GB + paid queries.
