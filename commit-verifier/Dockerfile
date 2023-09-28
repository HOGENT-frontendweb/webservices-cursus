FROM python:3-alpine

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

COPY commit-verifier.py /commit-verifier.py

ENTRYPOINT ["/commit-verifier.py"]
