FROM ubuntu:14.04

MAINTAINER Ben Heasly <benjamin.heasly@gmail.com>

# get dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libboost-all-dev \
    libeigen3-dev \
    libfftw3-dev
    libglewmx-dev \
    libilmbase-dev \
    libjpeg-dev \
    libopenexr-dev
    libpcrecpp0 \
    libpng12-dev \
    libxerces-c-dev \
    libxxf86vm-dev \
    mercurial \
    qt4-dev-tools \
    scons \
    zliblg-dev
RUN wget http://www.mitsuba-renderer.org/releases/current/trusty/collada-dom-dev_2.4.0-1_amd64.deb \
    && wget http://www.mitsuba-renderer.org/releases/current/trusty/collada-dom_2.4.0-1_amd64.deb
    && dpkg --install collada-dom_*.deb

# be a regular user
RUN groupadd -r mitsuba && useradd -r -g mitsuba mitsuba
USER mitsuba

# get mitsuba source
RUN mkdir /home/mitsuba/mitsuba-src \
    && cd /home/mitsuba/mitsuba-src \
    && hg clone https://www.mitsuba-renderer.org/hg/mitsuba
WORKDIR /home/mitsuba/mitsuba-src/mitsuba

## edit mitsuba source and config for 31 spectrum bands in 395-705nm
RUN sed 's/SAMPLES=[0-9]*/SAMPLES=31/' build/config-linux-gcc.py > config.py
RUN sed -e 's/SPECTRUM_MIN_WAVELENGTH[ ^I]*[0-9]*$/SPECTRUM_MIN_WAVELENGTH   395/' \
    -e 's/SPECTRUM_MAX_WAVELENGTH[ ^I]*[0-9]*$/SPECTRUM_MAX_WAVELENGTH   705/' \
    --in-place ~/include/mitsuba/core/spectrum.h

# build mitsuba
RUN scons

# make executables easy to find
ENV PATH /home/mitsuba/mitsuba-src/build/release/mitsuba:$PATH