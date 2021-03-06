FROM debian:jessie
MAINTAINER Denis Pasin

RUN groupadd -r node && useradd -m -g node node

# Gosu
ENV GOSU_VERSION 1.10

# MongoDB
ENV MONGO_VERSION 3.4.4
ENV MONGO_MAJOR 3.4
ENV MONGO_PACKAGE mongodb-org

# PhantomJS
ENV PHANTOM_VERSION 2.1.1

# build directories
ENV APP_SOURCE_DIR /opt/meteor/src
ENV APP_BUNDLE_DIR /opt/meteor/dist
ENV BUILD_SCRIPTS_DIR /opt/build_scripts

# Add entrypoint and build scripts
COPY scripts $BUILD_SCRIPTS_DIR
RUN chmod -R 750 $BUILD_SCRIPTS_DIR

# Define all --build-arg options
ENV APT_GET_INSTALL $APT_GET_INSTALL

ENV NODE_VERSION ${NODE_VERSION:-4.8.4}

ENV INSTALL_MONGO $INSTALL_MONGO
ENV INSTALL_PHANTOMJS $INSTALL_PHANTOMJS

ENV INSTALL_GRAPHICSMAGICK $INSTALL_GRAPHICSMAGICK

# Node flags for the Meteor build tool
ENV TOOL_NODE_FLAGS $TOOL_NODE_FLAGS

# optionally custom apt dependencies at app build time
RUN if [ "$APT_GET_INSTALL" ]; then apt-get update && apt-get install -y $APT_GET_INSTALL; fi

RUN $BUILD_SCRIPTS_DIR/install-deps.sh && \
      $BUILD_SCRIPTS_DIR/install-node.sh && \
      $BUILD_SCRIPTS_DIR/install-phantom.sh && \
      $BUILD_SCRIPTS_DIR/install-graphicsmagick.sh && \
      $BUILD_SCRIPTS_DIR/install-mongo.sh && \
      $BUILD_SCRIPTS_DIR/install-meteor.sh && \

# copy the app to the container
COPY . $APP_SOURCE_DIR

# install all dependencies, build app, clean up
RUN cd $APP_SOURCE_DIR && \
      $BUILD_SCRIPTS_DIR/build-meteor.sh && \

# Default values for Meteor environment variables
ENV ROOT_URL http://localhost
ENV MONGO_URL mongodb://127.0.0.1:27017/meteor
ENV PORT 3000

EXPOSE 3000

WORKDIR $APP_BUNDLE_DIR/bundle

# start the app
ENTRYPOINT ["./entrypoint.sh"]
CMD ["node", "main.js"]
