ARG IMAGE=intersystems/iris:2019.1.0S.111.0
ARG IMAGE=store/intersystems/iris:2019.1.0.511.0-community
ARG IMAGE=store/intersystems/iris:2019.2.0.107.0-community
#ARG IMAGE=intersystems/iris:2019.3.0.302.0
ARG IMAGE=store/intersystems/iris:2019.3.0.302.0-community
FROM $IMAGE

USER root

WORKDIR /opt/app
RUN chown irisowner /opt/app

USER irisowner

COPY  ./Installer.cls ./
COPY  ./src/cls ./src/cls
#COPY --chown=irisowner ./src/dfi ./src/dfi


RUN iris start $ISC_PACKAGE_INSTANCENAME quietly EmergencyId=sys,sys && \
    /bin/echo -e "sys\nsys\n" \
            " Do \$system.OBJ.Load(\"/opt/app/Installer.cls\",\"ck\")\n" \
            " Set sc = ##class(App.Installer).setup(, 3)\n" \
            " If 'sc do \$zu(4, \$JOB, 1)\n" \
            " halt" \
    | iris session $ISC_PACKAGE_INSTANCENAME && \
    /bin/echo -e "sys\nsys\n" \
    | iris stop $ISC_PACKAGE_INSTANCENAME quietly

CMD [ "-l", "/usr/irissys/mgr/messages.log" ]