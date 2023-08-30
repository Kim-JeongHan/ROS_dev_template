#!/bin/bash
# Basic entrypoint for ROS / Catkin Docker containers

# Source ROS 1
source /opt/ros/${ROS_DISTRO}/setup.bash
echo "Sourced ROS 1 ${ROS_DISTRO}"

# Source the base workspace, if built
if [ -f /upstream_ws/devel/setup.bash ]
then
  source /upstream_ws/devel/setup.bash
  echo "Sourced upstream_ws"
fi

# Source the overlay workspace, if built
if [ -f /overlay_ws/devel/setup.bash ]
then
  source /overlay_ws/devel/setup.bash
  # export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:$(find pkg)/share/worlds/models
  echo "Sourced overlay workspace"
fi

# Execute the command passed into this entrypoint
exec "$@"
