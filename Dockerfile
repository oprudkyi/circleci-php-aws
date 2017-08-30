FROM circleci/php:7.1.8-browsers

ARG NODE_VERSION
ENV NODE_VERSION ${NODE_VERSION:-6}

#install php modules for test purposes
RUN sudo apt-get install -y libpng-dev libmcrypt-dev && \
    sudo docker-php-ext-install gd bcmath mcrypt pdo pdo_mysql

#install node
RUN rm -rf ~/.nvm && \
    git clone https://github.com/creationix/nvm.git ~/.nvm && \
    (cd ~/.nvm && git checkout `git describe --abbrev=0 --tags`) && \
    bash -c "source ~/.nvm/nvm.sh && nvm install $NODE_VERSION"

#automatic include of npm
RUN echo "source /home/circleci/.nvm/nvm.sh" >> /home/circleci/.bashrc

#install gulp, bower
RUN bash -c "source ~/.nvm/nvm.sh && npm install --global gulp-cli && npm install --global bower"

#install aws cli
RUN sudo apt-get install -y python-pip && pip install --user awscli

RUN echo "export PATH=\$PATH:\$HOME/.local/bin" >> /home/circleci/.bashrc

RUN sudo apt-get remove -y libpng-dev libmcrypt-dev python-pip && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#auto auth to aws
ENTRYPOINT eval $($HOME/.local/bin/aws ecr get-login --region ${AWS_DEFAULT_REGION} --no-include-email) && /bin/bash