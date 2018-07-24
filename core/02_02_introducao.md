# Introdução {#sec:introducao}

O Django surgiu como uma ferramenta para agilizar o desenvolvimento de software web que, geralmente, tem algumas tarefas comuns [@djangohome]. Por exemplo, um software web tem uma interface administrativa, que permite cadastro e gerenciamento de dados, e uma interface pública, que permite consulta dos dados. O Django fornece mecanismos para tornar isso algo bastante rápido de construir.

A estrutura do Django é baseada no padrão de projeto **Model-View-Controller** (MVC). O MVC é um padrão de projeto arquitetural, o que significa que ele determina, inclusive, como os elementos do software comunicam entre si [@wiki:mvc]. Desta forma:

* **Model**: representa a camada de dados
* **View**: representa a interface
* **Controller**: representa a lógica que liga os dois elementos anteriores

Falando em **projeto**, esta é uma unidade importante do Django, que organiza o software em **projeto** e seus **aplicativos**. Tanto o projeto como o aplicativo são pacotes Python que podem ser desenvolvidos com o intuito de serem redistribuídos e reutilizados em outros softwares. Isso ficará mais claro nos capítulos seguintes.

## Ambiente do projeto e dependências 

Uma etapa importante de todo projeto Django é a configuração do ambiente. Antes de prosseguir, garanta que seu ambiente esteja com as ferramentas devidamente configuradas. Além disso, como há mais de uma forma de gerenciar pacotes do projeto, o restante desse livro não vai indicar qual ferramenta utilizar, mas considerar que você já sabe realizar essa tarefa.

O **Django** é distribuído como um pacote do Python. Isso significa que o ambiente do seu projeto precisa ter instalado o pacote `django`.

A seção a seguir demonstra como criar um **hello world** Django.

## Hello World, Django!

Crie uma pasta para seu projeto utilizando o programa `mkdir` (ou outra forma). Por exemplo, considere que a pasta do projeto se chame `hello-world-django`. Em seguida, acesse a pasta utilizando o programa `cd`.

```{style=nonumber .sh}
$ mkdir hello-world-django
$ cd hello-world-django
```

Realize a ativação do ambiente do projeto e instale o pacote `django`.

Com o pacote django instalado no ambiente do projeto é hora de criar um **projeto django**. Para isso, utilize o programa `django-admin`. O exemplo a seguir demonstra como criar o projeto `hello_world_django` na pasta local:

```{style=nonumber .sh}
$ django-admin startproject hello_world_django .
```

O programa `django-admin` está sendo executado utilizando, nesta ordem:

* `startproject`: o comando usado para criar um projeto (há outros)
* `hello_world_django`: o nome do projeto django
* `.`: o local do projeto django (`.` representa a pasta local)

Um **projeto django** possui uma estrutura de arquivos bastante particular, veja:

\dirtree{%
 .1 /.
 .2 Pipfile.
 .2 Pipfile.lock.
 .2 hello\_world\_django/.
 .3 \_\_init\_\_.py.
 .3 settings.py.
 .3 urls.py.
 .3 wsgi.py.
 .2 manage.py.
}

Além dos arquivos do gerenciador de pacotes **pipenv** (`Pipfile` e `Pipfile.lock`) estão:

* `manage.py`: um programa Python utilizado para executar determinadas tarefas no projeto django
* `hello_world_django`: o diretório que contém os arquivos do projeto.

Os arquivos do projeto django (no diretório `hello_world_django`):

* `__init__.py`: indica que o conteúdo da pasta atual pertence a um pacote Python
* `settings.py`: contém configurações do projeto django
* `urls.py`: contém especificações de caminhos, URLs e **rotas** do projeto
* `wsgi.py`: contém a configuração de execução do projeto django em um servidor web

Agora inicie o servidor web local para utilizar o software, executando:

```{style=nonumber .sh}
$ python manage.py runserver
```

Neste momento você verá uma saída como a seguinte:

```{style=nonumber}
Performing system checks...

System check identified no issues (0 silenced).

You have 14 unapplied migration(s). Your project may not work properly until you apply the migrations for app(s): admin, auth, contenttypes, sessions.
Run 'python manage.py migrate' to apply them.

July 12, 2018 - 00:30:14
Django version 2.0.7, using settings 'hello_world_django.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

Essa é a saída do programa Python `manage.py` com o argumento `runserver`.

Neste momento, use o browser e navegue até `http://localhost:8000` ou `http://127.0.0.1:8000`) e você algo como o que a [@fig:1-hello-world-inicio-browser].

![Janela do browser carregando o projeto django](./graphics/1-hello-world-inicio-browser.png){#fig:1-hello-world-inicio-browser}

A [@fig:1-hello-world-inicio-browser] apresenta a "página inicial" do projeto Django em execução. Ela é criada automaticamente pelo Django para servir como uma verificação rápida de que tudo está realmente funcionando no seu ambiente de desenvolvimneto.

Voltando ao prompt onde você iniciou o servidor web local, perceba que começam a aparecer algumas linhas de **log** à medida que o browser faz solicitações ao servidor web local, por exemplo:

```{style=nonumber}
[12/Jul/2018 00:32:50] "GET / HTTP/1.1" 200 16348
[12/Jul/2018 00:46:40] "GET / HTTP/1.1" 200 16348
[12/Jul/2018 00:46:40] "GET /static/admin/css/fonts.css HTTP/1.1" 200 423
```

Essas linhas são geradas pelo servidor web local para demonstrar que está ocorrendo alguma atividade, ou seja, está recebendo solicitações de um cliente (o seu browser).

## Hello World subiu às nuvens!

Enquanto você está utilizando seu servidor web local somente você consegue acessar seu software web. Por isso, seu software precisa ir para a nuvem. Para fazer isso vamos utilizar o **Heroku**. Antes de continuar, dois conceitos importantes:

* **ambiente de desenvolvimento**: corresponde ao seu computador, contendo os arquivos e recursos que você utiliza para desenvolver o software; o software utiliza o servidor web local e só pode ser acessado por você
* **ambiente de produção**: corresponde ao servidor remoto que você utiliza para disponibilizar seu software para outras pessoas (no caso, o Heroku)

É importante estabelecer uma **regra de ouro**: *só vai para a produção o que está 100% funcionando no ambiente de desenvolvimento*. Utilizar isso como um princípio garante que o software que as pessoas vão utilizar esteja realmente funcionando como deveria. Em outros capítulos você vai aprender a dar essa garantia de uma maneira mais sistemática. Por enquanto, garanta que o servidor web local não apresente erros.

### Configuração inicial do Heroku

O Heroku precisa que você crie o arquivo `Procfile`, que especifica configurções do ambiente de execução do Python, com o seguinte conteúdo:

```{style=nonumber}
web: gunicorn hello_world_django.wsgi --log-file -
```

Isso indica para o Heroku que ele vai utilizar o servidor web **gunicorn** que, diferentemente do servidor web local que você acabou de utilizar, é voltado para o ambiente de produção.

Instale o pacote `gunicorn` no seu ambiente de projeto.

Altere o arquivo `hello_world_django/settings.py`, modificando `ALLOWED_HOSTS` da seguinte forma:

```{style=nonumber .python}
ALLOWED_HOSTS = ['*']
```

Essa configuração permite que seu software possa ser acessado a partir de outros computadores (hosts).

Os arquivos são enviados ao Heroku por meio do **Git**, por isso  é necessário executar alguns procedimentos, começando pela inicialização do **repositório Git local**. Para isso execute o comando:

```{style=nonumber .sh}
$ git init
```

Depois configure informações do seu usuário:

```{style=nonumber .sh}
$ git config user.email "email@servidor.com"
$ git config user.name "Nome do usuário"
```

Substitua `email@servidor.com` pelo e-mail utilizado na sua conta do Heroku.

Em seguida adicione todos os arquivos do diretório autal em um **commit**:

```{style=nonumber .sh}
$ git add .
```

Depois faça um **commit**:

```{style=nonumber .sh}
$ git commit -m "Commit inicial para produção"
```

Crie o aplicativo do Heroku usando o comando a seguir:

```{style=nonumber .sh}
$ heroku create
```

A saída desse comando é importante e é mais ou menos assim:

```{style=nonumber}
Creating app... done, ⬢ lit-sands-61516
https://lit-sands-61516.herokuapp.com/ | https://git.heroku.com/lit-sands-61516.git
```

O nome do aplicativo é criado automaticamente pelo Heroku. Nesse caso é **lit-sands-61516**. A saída também informa a URL do aplicativo (`https://lit-sands-61516.herokuapp.com`) e a URL do **repositório Git remoto** (`https://git.heroku.com/lit-sands-61516.git`).

Em seguida, conecte seu repositório Git local com o repositório remoto:

```{style=nonumber .sh}
$ heroku git:remote -a lit-sands-61516
```

Isso faz com que o Git seja configurado para enviar arquivos para o Heroku.

Defina uma variável de ambiente para que o Heroku ignore arquivos estáticos (como arquivos CSS e JavaScript):

```{style=nonumber .sh}
$ heroku config:set DISABLE_COLLECTSTATIC=1
```

Envie o conteúdo do commit atual para o Heroku:

```{style=nonumber .sh}
$ git push heroku master
```

O comando atualiza (sincroniza) o repositório local e o repositório remoto. A saída desse programa deve ser algo parecido com isso:

```{style=nonumber}
Counting objects: 11, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (10/10), done.
Writing objects: 100% (11/11), 3.40 KiB | 1.13 MiB/s, done.
Total 11 (delta 0), reused 0 (delta 0)
remote: Compressing source files... done.
remote: Building source:
remote:
remote: -----> Python app detected
remote: -----> Installing python-3.6.6
remote: -----> Installing pip
remote: -----> Installing dependencies with Pipenv 2018.5.18…
remote:        Installing dependencies from Pipfile.lock (a8faad)…
remote: -----> Discovering process types
remote:        Procfile declares types -> web
remote:
remote: -----> Compressing...
remote:        Done: 59.3M
remote: -----> Launching...
remote:        Released v5
remote:        https://lit-sands-61516.herokuapp.com/ deployed to Heroku
remote:
remote: Verifying deploy... done.
To https://git.heroku.com/lit-sands-61516.git
 * [new branch]      master -> master
```

Pela saída é possível entender que o Heroku identifica o ambiente de execução do Python, as dependências do aplicativo (nesse caso estão no arquivo `Pipfile.lock`) e o tipo de processo que vai ser criado (`web`, utilizando `gunicorn`). Por fim o Heroku disponibiliza o aplicativo no ambiente de produção (faz o **deploy**).

Para concluir inicialize o aplicativo no Heroku utilizando o comando:

```{style=nonumber .sh}
$ heroku ps:scale web=1
```

A saída do comando deve ser algo como:

```{style=nonumber}
Scaling dynos... done, now running web at 1:Free
```

Pronto, agora acesse seu aplicativo no endereço informado pelo Heroku (nesse caso `https://lit-sands-61516.herokuapp.com/`). Perceba que o resultado é o mesmo da execução do seu aplicativo no ambiente local, como ilustra a [@fig:2-hello-world-remoto-browser].

![Janela do browser carregando o projeto django no ambiente remoto (produção)](./graphics/2-hello-world-remoto-browser.png){#fig:2-hello-world-remoto-browser}

Para verificar como seu aplicativo está configurado no Heroku, acesse sua *dashboard*, clique no aplicativo desejado e veja a área de configuração. A tela inicial (*Overview*) é semelhante ao que ilustra a [@fig:3-heroku-app-overview].

![Tela da visão geral do aplicativo no Heroku](./graphics/3-heroku-app-overview.png){#fig:3-heroku-app-overview}

A [@fig:3-heroku-app-overview] ilustra que a tela *Overview* apresenta os *Add-ons* instalados e permite acessar a configuração deles, mostra as informações dos *Dynos* (no caso, utilizando o nível *free*), as últimas atividades e dá acesso a outras configurações do aplicativo, como *Deploy*.


## Conclusão

Esse capítulo apresentou informações sobre o Django, o Heroku e como funciona o *workflow* (fluxo de trabalho) para utilizar o **Git** e o **Heroku CLI** para manter os repositórios local e remoto, bem como fazer o *deploy* da aplicação.

A [@fig:workflow-inicio] apresenta um resumo do *workflow* até aqui.

```{#fig:workflow-inicio .plantuml caption="Workflow para o desenvolvimento com Django e Heroku" format="eps"}
@startuml
start
if (não criou o projeto?) then (true)
    :Criar pasta do projeto e \ncontinuar a partir dela;
    :Ativar o ambiente do projeto;
    :Instalar o pacote **django**;
    :Criar um projeto Django\n""django-admin startproject projeto ."";
elseif (não configurou o Git?) then (true)
    :Iniciar o repositório Git local\n""git init"";
    :Definir as informações do usuário\n""git config"";
elseif (não configurou o Heroku?) then (true)
    :Fazer login\n""heroku login"";
    :Criar o arquivo **Procfile**;
    :Instalar o pacote **gunicorn**;
    :Alterar **ALLOW_HOSTS** no\n arquivo **settings.py**;
    :Criar o app no Heroku\n""heroku create"";
    :Conectar os repositórios\nGit local e remoto\n""heroku git:remote -a"";
    :Configurar Heroku para\nignorar arquivos estáticos\n""heroku config:set"";
endif
while (enquanto houver alterações) is (tem alterações)
    :Adicionar alterações para no próximo commit\n""git config add ."";
    :Fazer o commit\n""git commit"";
    :Fazer push para o remoto\n""git push heroku master"";
endwhile (sem alterações)
if (aplicativo heroku não iniciado?) then (true)
    :Iniciar o aplicativo no Heroku\n""heroku ps:scale web=1"";
endif
stop
@enduml
```

Como ilustra a [@fig:workflow-inicio] o processo é baseado na utilização de uma ferramenta para gerenciando do ambiente do projeto e suas dependências (**virtualenv** ou **pipenv**), **Git** e **Heroku**. Esse *workflow* continuará sendo utilizado e detalhado no restante do livro.

