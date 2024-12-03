FROM public.ecr.aws/paia-tech/ros2-humble:dev-20230907
ENV ROS2_WS /pros_ws
ENV ROS_DOMAIN_ID=1

COPY --from=base /workspaces/src ${ROS2_WS}/src

COPY ./src ${ROS2_WS}/src
WORKDIR ${ROS2_WS}
RUN . /opt/ros/humble/setup.sh && \
    colcon build --packages-select object_interfaces system_interfaces
RUN . install/setup.sh && \
    colcon build --packages-select pros_library
# RUN . install/setup.sh && \
#     colcon build --packages-select monitor_system lib_test
RUN . install/setup.sh && \
    colcon build --packages-select pros_library_py lib_test_py

# RUN . install/setup.sh && colcon build --packages-ignore template template_py
# RUN rm -rf src/monitor_system && rm -rf src/pros_library && rm -rf src/pros_arm

RUN echo "source ${ROS2_WS}/install/setup.bash " >> /.bashrc 
RUN echo "source /.bashrc" >> ~/.bashrc 

# RUN pip install ultralytics
# RUN pip install "numpy<2"
# RUN apt-get update && apt-get install -y ros-humble-cv-bridge


CMD ["bash","-l"]