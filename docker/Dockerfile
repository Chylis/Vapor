FROM ubuntu:15.10
MAINTAINER "Magnus Eriksson" <chylis88@gmail.com>

### Swift

ENV SWIFT_BRANCH swift-3.0.1-release
ENV SWIFT_VERSION swift-3.0.1-RELEASE 
ENV SWIFT_PLATFORM ubuntu15.10

# Install related packages and set LLVM 3.6 as the compiler
RUN apt-get update \
      && apt-get install -y lldb build-essential wget clang-3.6 curl libedit-dev libcurl3 python2.7 python2.7-dev libicu-dev rsync libxml2 git \
      && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.6 100 \
      && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.6 100 \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install lldb (and rename /usr/lib/lldb to 'lldb-disabled'. See https://marc.ttias.be/swift-dev/2016-04/msg00261.php)
#RUN mv /usr/lib/lldb /usr/lib/lldb-disabled

# Import the Swift GPG keys into keyring
RUN wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import - \
&& gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift

# Install Swift Ubuntu Snapshot and verify GPG signature
RUN SWIFT_ARCHIVE_NAME=$SWIFT_VERSION-$SWIFT_PLATFORM \
&& SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/$SWIFT_VERSION/$SWIFT_ARCHIVE_NAME.tar.gz \
&& wget $SWIFT_URL \
&& wget $SWIFT_URL.sig \
&& gpg --verify $SWIFT_ARCHIVE_NAME.tar.gz.sig \
&& tar -xvzf $SWIFT_ARCHIVE_NAME.tar.gz --directory / --strip-components=1 \
&& rm -rf $SWIFT_ARCHIVE_NAME* /tmp/* /var/tmp/*

# Set Swift Path
ENV PATH /usr/bin:$PATH

# Print Installed Swift Version
RUN swift --version


### Application

# Add the application folder to /tmp
ADD rest/ /tmp/

# Compile
RUN swift build -C /tmp/

# Run
CMD /tmp/.build/debug/App
