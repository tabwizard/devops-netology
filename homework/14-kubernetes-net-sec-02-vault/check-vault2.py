import os
import hvac
client = hvac.Client(
    url='http://172.17.0.3:8200',
    token=os.environ['VAULT_TOKEN']
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big netology secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)