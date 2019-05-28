################################################
################ STAGE 1: Build ################
# We label our stage as 'builder'
FROM node:12.3-stretch as builder

RUN apt-get update
RUN apt-get install -y ruby ruby-dev
RUN gem install compass
RUN gem install sass-css-importer --pre

RUN npm install -g grunt-cli
RUN npm install -g bower

COPY package.json package-lock.json ./

RUN npm set progress=false && npm config set depth 0 && npm cache clean --force

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm i
RUN mkdir /ng-app && cp -R ./node_modules ./ng-app

WORKDIR /ng-app

COPY . .

## Build the angular app in production mode and store the artifacts in dist folder
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN bower install
RUN npm install
RUN grunt prod

################################################
################ STAGE 2: Setup ################
FROM nginx:alpine

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From 'builder' stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=builder /ng-app/dist/community-app /usr/share/nginx/html

## Copy our default Nginx config
COPY ./default.conf /etc/nginx/nginx.conf

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

# Command to build: docker build -t mifos-legacy:latest .
# Command to run (dev): docker run -p 8080:80 mifos-legacy:latest