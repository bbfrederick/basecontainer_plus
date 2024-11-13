# Start from the latest basecontainer
FROM fredericklab/basecontainer:latest

USER root
RUN pwd
RUN mkdir /fsl;chown default /fsl

RUN /opt/miniforge3/bin/mamba create -y \
    -c https://fsl.fmrib.ox.ac.uk/fsldownloads/fslconda/public/ \
    -c conda-forge \
    -p /fsl \
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

# set up the bashrc file
RUN echo "# FSL Setup" >> ~/.bashrc
RUN echo "FSLDIR=/fsl" >> ~/.bashrc
RUN echo "PATH=${FSLDIR}/share/fsl/bin:${PATH}" >> ~/.bashrc
RUN echo "export FSLDIR PATH" >> ~/.bashrc
RUN echo ". ${FSLDIR}/etc/fslconf/fsl-devel.sh" >> ~/.bashrc

# Copy the install script
COPY ./buildfsl.sh ${FSLDIR}/src
COPY ./fsldeps.txt ${FSLDIR}/src

# now run it
#RUN cd $FSLDIR/src; ./buildfsl.sh

# Copy eye.mat
RUN mkdir -p $FSLDIR/data/atlases/bin
COPY ./eye.mat $FSLDIR/data/atlases/bin

ENV PATH="${PATH}:${FSLDIR}/bin"

ENV IS_DOCKER_8395080871=1

# make everything world accessible
RUN chmod -R a+rx /fsl

USER root

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
      org.label-schema.description="updated mambaforge container for fredericklab containers" \
      org.label-schema.url="http://nirs-fmri.net" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/bbfrederick/basecontainer_plus" \
      org.label-schema.version=$VERSION
