# Cloud Gaming PC

A gaming PC hosted in the cloud, deployed with Terraform


## Troubleshooting

### `VcpuLimitExceeded`

> Error: Error launching source instance: VcpuLimitExceeded: You have requested more vCPU capacity than your current vCPU limit of 0 allows for the instance bucket that the specified instance type belongs to. Please visit http://aws.amazon.com/contact-us/ec2-request to request an adjustment to this limit.

If you get this error, you need to go into the AWS Console and manually request an increase to the limit (which by default is set to 0). Apparently, this is to stop people from accidentally spinning up the more expensive instances and spending too much money (and to combat abuse).

1. Go to 'AWS Console > EC2 Dashboard'
2. Navigate to the 'Limits' screen
3. Find 'All G and VT Spot Instance Requests' (Limit type = Requested instances)
4. Request the service limit increase.

This will raise a ticket with AWS and they'll get back to you with a 'yes' or 'no' for your service limit increase. Wait a couple of days.

Stack Overflow (July 12, 2021). "[You have requested more vCPU capacity than your current vCPU limit of 0](https://stackoverflow.com/questions/68347900/you-have-requested-more-vcpu-capacity-than-your-current-vcpu-limit-of-0)". *[Archived](https://web.archive.org/web/20210925173200/https://stackoverflow.com/questions/68347900/you-have-requested-more-vcpu-capacity-than-your-current-vcpu-limit-of-0)*. Retrieved September 25, 2021.