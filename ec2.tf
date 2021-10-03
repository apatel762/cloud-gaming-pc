# A spot request for our Linux instance
#
# Using a spot request for this because it's cheaper than using an
# on-demand instance. The costs will otherwise add up quite quickly
# over time.
#

resource "aws_spot_instance_request" "workstation_instance" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.ubuntu_ami.image_id
  vpc_security_group_ids = [aws_security_group.workstation_security_group.id]

  # ensure that our spot request is one-time so it doesn't spin up
  # another instance if we lose it, and then the price goes down while
  # we aren't using it
  spot_type = "one-time"

  # ensure that terraform waits for the spot request to be fulfilled
  # when provisioning the infra; since we're bidding at on-demand price
  # we _shouldn't_ ever get timeouts here
  wait_for_fulfillment = true

  # allow the root volume size to be overridden by variables
  # and ensure that our instance is EBS Optimized
  ebs_optimized = true
  root_block_device {
    volume_size = var.root_volume_size
  }
}