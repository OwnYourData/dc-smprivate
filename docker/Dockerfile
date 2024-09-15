FROM oydeu/dc-base
LABEL maintainer="Christoph Fabianek <christoph@ownyourdata.eu>"

COPY . .
RUN bundle install

CMD ["./script/init.sh"]
EXPOSE 3000
