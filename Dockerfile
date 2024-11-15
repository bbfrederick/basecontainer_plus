# Start from the latest basecontainer
FROM fredericklab/basecontainer:latest-release AS build-stage

RUN mamba create -y \
    -c https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/ \
    -c conda-forge \
    -p ./fsl \
    make \
    cxx-compiler \
    boost-cpp \
    openblas \
    zlib \
    nlohmann_json \
    fsl-base \
    fsl-data_standard \
    fsl-misc_tcl \
    fsl-misc_scripts

RUN /opt/miniforge3/bin/activate /fsl

ENV FSLDIR=/fsl
ENV FSLDEVDIR=/fsl
ENV FSLCONFDIR=$FSLDIR/config
RUN source $FSLDIR/etc/fslconf/fsl-devel.sh

# Copy the install script
COPY ./buildfsl.sh ${FSLDIR}/src
COPY ./fsldeps.txt ${FSLDIR}/src

# now run it
RUN cd $FSLDIR/src; ./buildfsl.sh

# Copy eye.mat
RUN mkdir -p $FSLDIR/data/atlases/bin
COPY ./eye.mat $FSLDIR/data/atlases/bin

# Now copy built fsl into the deploy container
FROM fredericklab/basecontainer:latest-release AS deploy-stage
COPY --from=build-stage /fsl /fsl

# set up fsl variables
ENV FSLDIR=/fsl
ENV FSLDEVDIR=/fsl
ENV FSLCONFDIR=$FSLDIR/config
RUN source $FSLDIR/etc/fslconf/fsl-devel.sh

# set the PATH
ENV PATH="${PATH}:${FSLDIR}/bin"

ENV IN_DOCKER_CONTAINER=1
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /root; TZ=GMT date "+%Y-%m-%d %H:%M:%S" > buildtime-basecontainer_plus

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="basecontainer_plus" \
      org.label-schema.description="updated mambaforge container for fredericklab containers" \
      org.label-schema.url="http://nirs-fmri.net" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/bbfrederick/basecontainer_plus" \
      org.label-schema.version=$VERSION
