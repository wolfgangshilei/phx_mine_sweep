#! /bin/bash

APP_NAME=`cat mix.exs | grep 'app:' | cut -d: -f3 | tr -d ,`
APP_VSN=`cat mix.exs | grep 'version' | cut -d: -f2 | tr -d ',\"\ '`
HEROKU_APP_NAME=mine-sweep-1008

docker build \
       --build-arg APP_NAME=$APP_NAME  \
       --build-arg APP_VSN=$APP_VSN \
       --build-arg SKIP_PHOENIX=true \
       --build-arg SECRET_BASE_KEY=$SECRET_BASE_KEY \
       -t $APP_NAME:$APP_VSN .

echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin registry.heroku.com

docker tag $APP_NAME:$APP_VSN registry.heroku.com/$HEROKU_APP_NAME/web
docker push registry.heroku.com/$HEROKU_APP_NAME/web
