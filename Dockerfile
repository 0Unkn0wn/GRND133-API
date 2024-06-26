FROM python:3.10

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./app /code/app

COPY ./genenv.py /code/genenv.py

RUN touch /code/.env

#credits for the idea to mount them like this go to https://github.com/docker/build-push-action/issues/390#issuecomment-866761773
RUN --mount=type=secret,id=DB_URL \
  --mount=type=secret,id=DB_USER \
  --mount=type=secret,id=DB_PASSWORD \
  --mount=type=secret,id=JWT_SECRET_KEY \
  export DB_URL=$(cat /run/secrets/DB_URL) && \
  export DB_USER=$(cat /run/secrets/DB_USER) && \
  export DB_PASSWORD=$(cat /run/secrets/DB_PASSWORD) && \
  export JWT_SECRET_KEY=$(cat /run/secrets/JWT_SECRET_KEY) && \
  python genenv.py 


EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host=0.0.0.0", "--port=8000", "--log-level=debug"]        