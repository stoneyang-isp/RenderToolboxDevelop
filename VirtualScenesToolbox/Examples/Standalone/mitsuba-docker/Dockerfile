FROM ubuntu:14.04

MAINTAINER Ben Heasly <benjamin.heasly@gmail.com>

### get dependencies
RUN apt-get update && apt-get install -y\
    build-essential \
    git \
    libboost-all-dev \
    libeigen3-dev \
    libfftw3-dev \
    libglew-dev \
    libglewmx-dev \
    libilmbase-dev \
    libjpeg8-dev \
    libjpeg-dev \
    libopenexr-dev \
    libpcrecpp0 \
    libpng12-dev \
    libxerces-c3.1 \
    libxerces-c-dev \
    libx11-dev \
    libxxf86vm-dev \
    mercurial \
    mercurial-common \
    qt4-dev-tools \
    scons \
    unzip \
    x11proto-xf86vidmode-dev \
    zlib1g-dev

### extra Mitsuba dependencies
RUN wget http://www.mitsuba-renderer.org/releases/current/trusty/collada-dom-dev_2.4.0-1_amd64.deb \
    && http://www.mitsuba-renderer.org/releases/current/trusty/collada-dom_2.4.0-1_amd64.deb \
    && dpkg --install collada-dom_*.deb

### be a regular user
RUN groupadd -r rtb && useradd -r -g rtb rtb
USER rtb

### add our Render Toolbox config file
ADD RenderToolboxConfig.m /home/rtb

### add runtime used by Matlab compiled executables
ADD MCR_R2015a_glnxa64_installer.zip
RUN unzip MCR_R2015a_glnxa64_installer.zip -d matlab-runtime

### add our Matlab compiled executable
ADD LinuxRecipeExecutor.zip
RUN unzip LinuxRecipeExecutor.zip -d recipe-executor

### get our Matlab toolboxes
git clone git@github.com:Psychtoolbox-3/Psychtoolbox-3.git
git clone git@github.com:DavidBrainard/RenderToolbox3.git
git clone git@github.com:DavidBrainard/RenderToolboxDevelop.git

### get mitsuba source
RUN mkdir -p /home/rtb/mitsuba-src \
    && cd /home/rtb/mitsuba-src \
    && hg clone https://www.mitsuba-renderer.org/hg/mitsuba
WORKDIR /home/rtb/mitsuba-src/mitsuba

### build and install RBG Mitsuba
RUN cp build/config-linux-gcc.py > config.py \
    && scons \
    && mkdir -p /home/rtb/mitsuba-rgb \
    && cp build/release /home/rtb/mitsuba-rgb

### edit mitsuba source and config for 31 spectrum bands in 395-705nm
RUN sed 's/SAMPLES=[0-9]*/SAMPLES=31/' build/config-linux-gcc.py > config.py
RUN sed -e 's/SPECTRUM_MIN_WAVELENGTH[ ^I]*[0-9]*$/SPECTRUM_MIN_WAVELENGTH   395/' \
    -e 's/SPECTRUM_MAX_WAVELENGTH[ ^I]*[0-9]*$/SPECTRUM_MAX_WAVELENGTH   705/' \
    --in-place include/mitsuba/core/spectrum.h

### build and install multispectral Mitsuba
RUN scons \
    && mkdir -p /home/rtb/mitsuba-multi \
    && cp build/release /home/rtb/mitsuba-multi

### run out Matlab compiled executable and point it at the runtime
### TODO: reorder arguments to make it easy to pass in RenderToolboxConfig.m
### TODO: how to pass the actual recipe to the container at run time?
ENTRYPOINT ["/home/rtb/recipe-executor/for_redistribution_files_only/run_RecipeExecutor.sh" \
    "home/rtb/matlab-runtime" ]
