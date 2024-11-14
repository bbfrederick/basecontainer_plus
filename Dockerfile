# Start from the latest basecontainer
FROM fredericklab/basecontainer:latest as base

ENV FSLDIR          "/fsl"
ENV DEBIAN_FRONTEND "noninteractive"

RUN apt update  -y && \
    apt upgrade -y && \
    apt install -y    \
      python          \
      wget            \
      file            \
      dc              \
      mesa-utils      

#      pulseaudio      \
#      libquadmath0    \
#      libgtk2.0-0     \
#      firefox         \
#      libgomp1

RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/releases/fslinstaller.py && \
    python ./fslinstaller.py -d /usr/local/fsl/

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# make everything world accessible
RUN chmod -R a+rx /fsl

#FROM base as deploy

RUN cd /root; TZ=GMT date "+%Y-%m-%d %H:%M:%S" > buildtime-basecontainer_plus

USER default

RUN echo "# FSL Setup" >> ~/.bashrc
RUN echo "FSLDIR=/fsl" >> ~/.bashrc
RUN echo "PATH=${FSLDIR}/share/fsl/bin:${PATH}" >> ~/.bashrc
RUN echo "export FSLDIR PATH" >> ~/.bashrc
RUN echo ". ${FSLDIR}/etc/fslconf/fsl-devel.sh" >> ~/.bashrc

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="basecontainer_plus" \
      org.label-schema.description="basecontainer with parts of FSL for fredericklab containers" \
      org.label-schema.url="http://nirs-fmri.net" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/bbfrederick/basecontainer_plus" \
      org.label-schema.version=$VERSION
