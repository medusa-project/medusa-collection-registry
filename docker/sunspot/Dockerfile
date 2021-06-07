# invocation
# docker build -t medusa-sunspot .
# docker run --name medusa-sunspot -p 8982:8983 -d medusa-sunspot
# ENV=<env>
# curl "http://localhost:8982/solr/admin/cores?action=CREATE&name=$ENV&instanceDir=$ENV"

FROM solr:6

USER root

COPY *.* ./

# test env
RUN mkdir -p server/solr/test/conf
RUN cp _rest_managed.json server/solr/test/conf/
RUN cp admin-extra.html server/solr/test/conf/
RUN cp currency.xml server/solr/test/conf/
RUN cp elevate.xml server/solr/test/conf/
RUN cp mapping-ISOLatin1Accent.txt server/solr/test/conf/
RUN cp protwords.txt server/solr/test/conf/
RUN cp schema.xml server/solr/test/conf/
RUN cp scripts.conf server/solr/test/conf/
RUN cp solrconfig.xml server/solr/test/conf/
RUN cp spellings.txt server/solr/test/conf/
RUN cp synonyms.txt server/solr/test/conf/

# development env
RUN mkdir -p server/solr/development/conf
RUN cp _rest_managed.json server/solr/development/conf/
RUN cp admin-extra.html server/solr/development/conf/
RUN cp currency.xml server/solr/development/conf/
RUN cp elevate.xml server/solr/development/conf/
RUN cp mapping-ISOLatin1Accent.txt server/solr/development/conf/
RUN cp protwords.txt server/solr/development/conf/
RUN cp schema.xml server/solr/development/conf/
RUN cp scripts.conf server/solr/development/conf/
RUN cp solrconfig.xml server/solr/development/conf/
RUN cp spellings.txt server/solr/development/conf/
RUN cp synonyms.txt server/solr/development/conf/

# demo env
RUN mkdir -p server/solr/demo/conf
RUN cp _rest_managed.json server/solr/demo/conf/
RUN cp admin-extra.html server/solr/demo/conf/
RUN cp currency.xml server/solr/demo/conf/
RUN cp elevate.xml server/solr/demo/conf/
RUN cp mapping-ISOLatin1Accent.txt server/solr/demo/conf/
RUN cp protwords.txt server/solr/demo/conf/
RUN cp schema.xml server/solr/demo/conf/
RUN cp scripts.conf server/solr/demo/conf/
RUN cp solrconfig.xml server/solr/demo/conf/
RUN cp spellings.txt server/solr/demo/conf/
RUN cp synonyms.txt server/solr/demo/conf/

# production env
RUN mkdir -p server/solr/production/conf
RUN cp _rest_managed.json server/solr/production/conf/
RUN cp admin-extra.html server/solr/production/conf/
RUN cp currency.xml server/solr/production/conf/
RUN cp elevate.xml server/solr/production/conf/
RUN cp mapping-ISOLatin1Accent.txt server/solr/production/conf/
RUN cp protwords.txt server/solr/production/conf/
RUN cp schema.xml server/solr/production/conf/
RUN cp scripts.conf server/solr/production/conf/
RUN cp solrconfig.xml server/solr/production/conf/
RUN cp spellings.txt server/solr/production/conf/
RUN cp synonyms.txt server/solr/production/conf/

RUN chown -R solr server/solr

USER solr
