FROM ubuntu:latest

RUN apt-get update \
	&& apt-get install python -y \
	&& apt-get install git -y \
	&& cd /home \
	&& git clone https://github.com/ops-school/session-monitoring.git \
	&& chmod +x /home/session-monitoring/training_session/my_dummy_exporter.py
	
WORKDIR /home/session-monitoring/training_session/
 	 
EXPOSE 65433

CMD python my_dummy_exporter.py
