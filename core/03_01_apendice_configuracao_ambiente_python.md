# Configuração do ambiente Python {#sec:apendice-1}
 
## Windows

Faça download do instalador do Python na [página de releases para windows](https://www.python.org/downloads/windows/)^[Acesse: <https://www.python.org/downloads/windows/>]. 

Depois de concluir o download execute o instalador e siga os passos apresentados nas telas.

Verifique a instalação obtendo a versão do Python, executando o seguinte comando:

```{style=nonumber .sh}
$ python --version
```

O comando apresenta a versão instalada. 


## Linux (Ubuntu)

Antes de continuar, atualize seus repositórios `apt` executando o comando:

```{style=nonumber .sh}
$ sudo apt-get update
```

Execute o comando a seguir para instalar o python 3:

```{style=nonumber .sh}
$ sudo apt-get install build-essential python3 python3-pip python3-dev python3-setuptools
```

Esse comando instala: **Python**, **pip** e pacotes para um ambiente completo de desenvolvimento Python.

Geralmente a instalação deste pacote tornará disponíveis os programas `python3` e `pip3`. Lembre-se disso porque distribuições Linux costumam usar esse recurso diferenciar o **Python 2.x** do **Python 3.x**.

## Ambiente com permissões restritas

Se você estiver utilizando um ambiente com restrições de permissões (ie. não tem acesso root ou administrator) adicione a opção `--user` toda vez que utilizar o comando  `pip` antes de habilitar um ambiente do projeto. Isso fará com que os pacotes sejam instalados no diretório do seu usuário e não haverá problemas com permissões. Por exemplo, para instalar o **pipenv**:

```{style=nonumber}
$ pip install pipenv --user
```

## Usando o virtualenv

Instale o **virtualenv** utilizando **pip**:

```{style=nonumber .sh}
$ pip install virtualenv
```

### Criação de um ambiente do projeto

A criação de um ambiente do projeto permite diferenciar pacotes e versões de pacotes do ambiente global do python.

A partir da pasta do projeto execute:

```{style=nonumber .sh}
$ virtualenv env
```

Nesse caso será criado um ambiente python para o projeto local chamado **env** e estará na pasta `./env`, contendo os programas principais: `python`, `pip`, `activate` e `deactivate`. Os dois últimos são responsáveis, respectivamente, por ativar e desativar o ambiente local. Você pode mudar o nome do ambiente, se preferir.

### Ativação do ambiente

A ativação do ambiente é um pouco diferente entre Windows e Linux. A partir da pasta do projeto, execute:

no Windows:

```{style=nonumber .sh}
$ env\Scripts\activate
```

no Linux:

```{style=nonumber .sh}
$ source env/bin/activate
```

A indicação de que o comando foi alterado com sucesso é a presença de `(env)` no prompt e, além disso, você pode executar o comando a seguir para obter a lista de pacotes instalados no ambiente local:

```{style=nonumber .sh}
$ pip list
```

Se tudo estiver correto, você verá uma lista com:

* `pip`
* `setuptools`
* `wheel`

Perceba que não é mais necessário usar os programas `pip` ou `pip3` para diferenciar a versão do Python. Apenas `pip` é necessário.

Na prática, o programa `activate` configura o ambiente do projeto definindo, principalmente, variáveis de ambiente.


### Desativação do ambiente

Para desativar o ambiente do projeto e retornar ao ambiente global do Python execute o programa `deactivate`:

```{style=nonumber .sh}
$ deactivate
```

### Instalação de pacotes

Uma vez que o ambiente do projeto esteja ativado é possível instalar pacotes utilizando o **pip**, como o exemplo a seguir, que mostra como instalar o django:

```{style=nonumber .sh}
$ pip install django
```

É importante lembrar que os pacotes são instalados apenas no ambiente do projeto. 

É uma prática comum utilizar o arquivo `requirements.txt` para listar as dependências (os pacotes) do ambiente. Se o projeto não tiver esse arquivo, é possível gerá-lo utilizando o **pip**, como mostra o exemplo:

```{style=nonumber .sh}
$ pip freeze > requirements.txt
```

O comando obtém a lista dos pacotes instalados no ambiente do projeto e cria o arquivo `requirements.txt`.

Também é possível instalar os pacotes a partir de um arquivo `requirements.txt`, também utilizando **pip**:

```{style=nonumber .sh}
$ pip install -r requirements.txt
```

Nesse caso o **pip** obtém os pacotes e suas especificações de versões do arquivo `requirements.txt` e instala no ambiente do projeto.

## Usando o pipenv

Para instalar o **pipenv** utilize o comando:

```{style=nonumber .sh}
$ pip install pipenv
```

Para detalhes da instalação leia a [documentação oficial do **pipenv**](https://docs.pipenv.org/)^[Acesse: <https://docs.pipenv.org/>].

Depois da instalação do **pipenv** você poderá utilizá-lo para criar um ambiente Python de forma semelhante ao **virtualenv**. 

### Ativação do ambiente 

Para ativar o ambiente do projeto utilize o comando a partir da pasta do projeto:

```{style=nonumber .sh}
$ pipenv shell
```

Esse processo é semelhante ao utilizado no **virtualenv** e faz a mesma coisa: configura variáveis de ambiente e modifica o prompt para mostrar uma identificação do ambiente.

### Desativação do ambiente 

A desativação do ambiente do projeto é feita com o programa `exit`, portanto basta executá-lo:

```{style=nonumber .sh}
$ exit
```

### Instalação de pacotes

A instalação de pacotes é feita com o programa `pipenv`:

```{style=nonumber .sh}
$ pipenv install django
```

Nesse caso o programa `pipenv` instala o pacote `django` no ambiente do projeto. 

O **pipenv** mantém dois arquivos para o gerenciamento das dependências (pacotes) do projeto:

* `Pipfile`
* `Pipfile.lock`

Esses arquivos armazenam as informações sobre o ambiente do projeto e sobre os pacotes.

Para instalar pacotes a partir de um arquivo `requirements.txt` use o comando:

```{style=nonumber .sh}
$ pipenv install -r requirements.txt
```
