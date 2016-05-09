FROM cloudfoundry/cflinuxfs2

RUN apt-get install -y ccache
RUN gem install bundler --no-ri --no-rdoc

RUN mkdir /binary-builder
ADD Gemfile* /binary-builder/

WORKDIR /binary-builder
RUN bundler install -j4

