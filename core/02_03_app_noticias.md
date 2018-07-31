# Aplicativo Notícias {#sec:app-noticias}

O Capítulo [-@sec:introducao] apresentou os conceitos e as ferramentas básicas para o desenvolvimento de aplicativos em Django. Entretanto, o aplicativo **hello-world-django** tem apenas o conteúdo padrão de um aplicativo Django e tem o objetivo de explorar as funcionalidades deste framework. 

Este capítulo apresenta o aplicativo **noticias** e vai explorar conceitos de persistência de dados em bancos de dados, mapeador objeto-relacional (ORM) do Django e testes.

## Configuração inicial

Siga o *workflow* apresentado no Capítulo [-@sec:introducao] para criar a pasta `noticias`, configurar o ambiente do projeto com o pacote `django`, e criar o projeto Django `projeto_noticias`. Se estiver com dúvidas, não se procupe, volta lá no Capítulo [-@sec:introducao] sempre que precisar, depois continua.

## Projeto e aplicativo Django

O Django organiza um software em duas unidades principais: **projeto** e **aplicativo**. Um software Django deve conter um projeto e um projeto pode conter nenhum ou muitos aplicativos. Tanto projeto quanto aplicativo podem ser redistribuídos e utilizados em outros softwares Django.

## Criando o aplicativo

Para criar o aplicativo **app_noticias** execute o comando:

```{style=nonumber .sh}
$ python manage.py startapp app_noticias
```

Altere o arquivo `projeto_noticias/settings.py`, modificando `INSTALLED_APPS` para incluir `app_noticias`:

```{.python}
...
# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'app_noticias',
]
...
```

## Criando o banco de dados

Por enquanto vamos utilizar um banco de dados **SQLite**, que não é indicado para ambiente de produção, mas funciona muito bem em ambiente de desenvolvimento. Para criar o banco de dados execute:

```{style=nonumber .sh}
$ python manage.py migrate
```

Você deve ver uma saída parecida com a seguinte:

```{style=nonumber}
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, sessions
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying auth.0007_alter_validators_add_error_messages... OK
  Applying auth.0008_alter_user_username_max_length... OK
  Applying auth.0009_alter_user_last_name_max_length... OK
  Applying sessions.0001_initial... OK
```

Esse comando cria o arquivo `db.sqlite3`, que representa o banco de dados **SQLite**.

Esse processo utiliza o recurso de **migrations**, que representam uma forma de definir a estrutura do banco de dados sem ter que lidar diretamente com um gerenciador ou com instruções em linguagem **SQL**. Isso funciona porque o Django disponibiliza uma ferramenta **ORM** (de *Object-Relational Mapper*). 

Um ORM permite que o desenvolvedor Django mantenha o foco em código Python, apenas, e é responsável por toda a comunicação com o banco de dados (no caso o **SQLite**). Essa é uma abordagem conhecida como **model first**.

## Estrutura do projeto

A estrutura do projeto já começa ficar maior e, para ajudar a esclarecer, a [@fig:estrutura-noticias] apresenta uma ilustração.

```{#fig:estrutura-noticias .plantuml caption="Estrutura do projeto Noticias" format="eps" width=10cm}
@startuml
package projeto_noticias [
""__init__.py""
""settings.py""
""urls.py""
""wsgi.py""
]
package app_noticias [
""__init__.py""
""admin.py""
""apps.py""
""migrations/""
""  __init__.py""
""models.py""
""tests.py""
""views.py""
]
database Database [
--
""db.sqlite3""
--
]
projeto_noticias -> app_noticias: depende de/importa
app_noticias <--> Database: acessa BD
@enduml
```

A [@fig:estrutura-noticias] omitiu os arquivos de dependências (`Pipfile` e `Pipfile.lock`) e o arquivo `manage.py`.

Como você já conhece a estrutura de um **projeto Django**, a composição de um **aplicativo Django** é a seguinte:

* `__init__.py`: indica que o conteúdo da pasta é de um pacote Django
* `admin.py`: contém definições da **interface administrativa**
* `apps.py`: contém configurações do aplicativo, como seu nome
* `migrations`: pasta que contém migrations
* `models.py`: contém definições de **Model**
* `tests.py`: contém definições de testes
* `views.py`: contém definições de **View**

A interface administrativa é fornecida por um pacote do Django chamado `admin` (está habilitado por padrão no arquivo `settings.py`, `INSTALLED_APPS`).

Os arquivos `models.py` e `views.py` representam uma parte importante do modelo MVC: `models.py` representa o modelo de dados do aplicativo, representado conforme regras do ORM do Django. `views.py` representa as definições de views, que se tornarão formas de comunicação com o cliente. Detalhes destes elementos serão apresentados nas seções seguintes.

## Criação do Model

Para o aplicativo **app_noticias** precisamos de um modelo de dados que permita representar uma notícia e seu conteúdo. Fazemos isso modificando o arquivo `app_noticias/models.py` para conter o seguinte:

```{#lst:app_noticias_noticia_model_inicio .python caption="Código inicial do model Noticia"}
from django.db import models

class Noticia(models.Model):
    conteudo = models.TextField()
```

O que (@lst:app_noticias_noticia_model_inicio) apresenta é a classe `Noticia`, que herda de `models.Model` (`Model` é uma classe fornecida por `django.db.models`). O model `Noticia`  contém o campo `conteudo`. Uma instância da classe `TextField` (fornecida por `django.db.models`) é utilizada para indicar que o campo `conteudo` é um campo de texto (contém texto). Há mais tipos de campos para representar datas, números e outros. 

O próximo passo é criar um **migration**:

```{style=nonumber .sh}
$ python manage.py makemigrations
```

Esse comando cria um arquivo Python (com um nome gerado automaticamente) dentro da pasta `app_noticias/migrations`. Sem entrar em detalhes agora, o importante é saber que esse arquivo contém uma descrição utilizada pelo ORM do Django para criar ou atualizar o banco de dados de forma apropriada, conforme o **Model**.

Para aplicar a migration (criar a tabela para o Model no banco de dados) basta executar:

```{style=nonumber .sh}
$ python manage.py migrate
```

Você também pode ver todas as migrations (aplicadas ou não) executando o comando:

```{style=nonumber .sh}
$ python manage.py showmigrations
```

Neste momento a saída desse comando seria algo como o seguinte:

```{style=nonumber}
admin
 [X] 0001_initial
 [X] 0002_logentry_remove_auto_add
app_noticias
 [X] 0001_initial
auth
 [X] 0001_initial
 [X] 0002_alter_permission_name_max_length
 [X] 0003_alter_user_email_max_length
 [X] 0004_alter_user_username_opts
 [X] 0005_alter_user_last_login_null
 [X] 0006_require_contenttypes_0002
 [X] 0007_alter_validators_add_error_messages
 [X] 0008_alter_user_username_max_length
 [X] 0009_alter_user_last_name_max_length
contenttypes
 [X] 0001_initial
 [X] 0002_remove_content_type_name
sessions
 [X] 0001_initial
```

Isso permite identificar quais migrations de quais aplicativos Django estão aplicadas (marcadas com `[X]`) ou não (marcadas com `[ ]`).

## Interface Administrativa ou Django Admin

O **Django Admin** fornece uma interface administrativa que permite, entre outras coisas, o gerenciamento do banco de dados. Há vários componentes que fornecem funcionalidades padrão para executar quatro tarefas de software que acessa banco de dados que são conhecidas como **CRUD**, que vem de:

* **C - CREATE** representa a funcionalidade de cadastrar
* **R - RETRIEVE** representa a funcionalidade de consultar, recuperar dados
* **U - UPDATE** representa a funcionalidade de atualizar
* **D - DELETE** representa a funcionalidade de deletar, excluir

Crie o **super usuário** para o Django Admin utilizando o comando a seguir e seguindo as instruções da tela:

```{style=nonumber .sh}
$ python manage.py createsuperuser
```

Agora inicie o servidor web local.

```{style=nonumber .sh}
$ python manage.py runserver
```

Acesse o software no browser, direcionando para o caminho `/admin`) (ie. `http://localhost:8000/admin`). Você verá uma tela de autenticação semelhante à ilustrada pela figura [@fig:4-app-noticias-django-admin-login].

![Tela de autenticação do Django Admin](./graphics/4-app-noticias-django-admin-login.png){#fig:4-app-noticias-django-admin-login}

A [@fig:4-app-noticias-django-admin-login] mostra que a tela de autenticação apresenta um formulário com dois campos: "Username" e "Password", além do botão "Log in".

Preencha o formulário utilizando as informações que você forneceu ao criar o super usuário e clique no botão "Log in". Se a autenticação for bem sucedida você verá a tela inicial da administração do site, como ilustra a [@fig:5-app-noticias-django-admin-home].

![Tela inicial da administração do site no Django Admin](./graphics/5-app-noticias-django-admin-home.png){#fig:5-app-noticias-django-admin-home}

A [@fig:5-app-noticias-django-admin-home] mostra que a tela inicial da administração do site permite acessar diversas funcionalidades, de cima para baixo:

* na barra de menu global há links: para a página inicial do site (fora do Django admin), para a tela de atualização da senha e para sair do Django admin
* Na seção "Authentication and Authorization": há links para o gerenciamento de grupos e usuários
* Na seção "Recent actions" há uma lista das ações mais recentes do usuário (nesse caso, nenhuma ação mais recente)

## Personalizando o idioma e o fuso horário

O Django foi desenvolvido com foco na **internacionalização**, a tarefa de adaptar a interface gráfica conforme o idioma e as necessidades do usuário. 

Você deve ter percebido que as telas do Django admin estão com textos no idioma Inglês, mas seria muito melhor, considerando que o software de notícias seria utilizado por brasileiros, que o idioma fosse o Português. Para fazer isso altere o arquivo `projeto_noticias/settings.py` da seguinte forma:

```{.python}
...
# Internationalization
# https://docs.djangoproject.com/en/2.0/topics/i18n/

LANGUAGE_CODE = 'pt-br'

TIME_ZONE = 'America/Araguaina'
...
```

Perceba que foram alterados os valores de duas constantes: `LANGUAGE_CODE`, para `'pt-br'`, e `TIME_ZONE`, para `'America/Araguaina'`. Essas strings alteram o idioma e o fuso horário, respectivamente.

Se o servidor web local ainda estiver em execução, perceba que ele recarregou novamente o projeto Django, para ler as novas configurações. Senão, inicie o servidor web local. Por fim, perceba que o idioma da interface gráfica está como esperado. Por exemplo, agora você deve estar vendo "Administração do Django" bem no início da página, ao invés de "Django administration".

## Habilitando o aplicativo de notícias no Django Admin

Como você percebeu ainda não é possível cadastrar as notícias por meio do Django Admin. Para resolver isso, modifique o conteúdo do arquivo `app_noticias/admin.py` para o seguinte:

```{#lst:app_noticias_admin_inicio .python caption="Código inicial para configuração do Django admin"}
from django.contrib import admin
from .models import Noticia

@admin.register(Noticia)
class NoticiaAdmin(admin.ModelAdmin):
    pass
```

[@lst:app_noticias_admin_inicio] mostra a configuração do Django admin para o `app_noticias`:

1. importar o model `Noticia` (linha 4)
2. chamar a **função de anotação** `admin.register()` e indicar o model `Noticia`
3. declarar a classe `NoticiaAdmin`, que herda de `ModelAdmin` (disponível em `django.contrib.admin`).

Uma **função de anotação** (**decorator** ou **annotation function**) é um recurso do Python para adicionar metadados a uma classe, por exemplo. O código demonstra que é criada uma interface de administração para o model `Noticia`. Para ver, na prática, o que isso significa, veja a atualização na tela inicial do Django admin, como ilustra a [@fig:6-app-noticias-django-admin-home]


![Tela inicial da administração do site no Django Admin mostrando o aplicativo "APP_NOTICIAS"](./graphics/6-app-noticias-django-admin-home.png){#fig:6-app-noticias-django-admin-home}


A [@fig:6-app-noticias-django-admin-home] mostra que há uma nova seção de aplicativos chamada "APP_NOTICIAS", que permite gerenciar "Noticias". Clique no link "Noticias" para acessar a tela da lista de notícias, ilustrada pela [@fig:7-app-noticias-django-admin-noticia-home].


![Tela da lista de notícias](./graphics/7-app-noticias-django-admin-noticia-home.png){#fig:7-app-noticias-django-admin-noticia-home}


A [@fig:7-app-noticias-django-admin-noticia-home] mostra a interface gráfica padrão para a lista de notícias. A tela mostra que não há notícias cadastradas e dá acesso ao formulário de cadastro, por meio do botão "Adicionar noticia". Ao clicar no botão aparece a tela de cadastro de notícia, como mostra a [@fig:8-app-noticias-django-admin-noticia-add].

![Tela do cadastro de notícia](./graphics/8-app-noticias-django-admin-noticia-add.png){#fig:8-app-noticias-django-admin-noticia-add}

A [@fig:8-app-noticias-django-admin-noticia-add] apresenta um formulário contendo um campo "Conteudo" (`textarea`). Além disso a interface padrão contém três botões: "Salvar e adicionar outro(a)", "Salvar e continuar editando" e "Salvar", que são autoexplicativos. Preencha o formulário para cadastrar uma notícia e clique em um dos botões. Ao clicar no botão "Salvar" o software apresentará a tela da lista de notícias, mas agora com registros, como ilustra a [@fig:9-app-noticias-django-admin-noticia-lista].

![Tela da lista de notícias apresentando registros](./graphics/9-app-noticias-django-admin-noticia-lista.png){#fig:9-app-noticias-django-admin-noticia-lista}

A [@fig:9-app-noticias-django-admin-noticia-lista] mostra uma notificação indicando que uma notífica foi cadastrada com sucesso (abaixo do *breadcrumbs*) e que é possível selecionar registros e clicar sobre um deles para editá-lo. Experimente brincar um pouco com essa interface de administração de dados.

## Incrementando o modelo de dados

A interface administrativa funciona bem, mas não está muito interessante apresentar cada item da lista com "Noticia object(n)", não é? Vamos melhorar isso. Modifique o arquivo `app_noticias/models.py` para o seguinte:

```{.python}
from django.db import models

class Noticia(models.Model):
    class Meta:
        verbose_name = 'Notícia'
        verbose_name_plural = 'Notícias'

    titulo = models.CharField('título', max_length=128)
    conteudo = models.TextField('conteúdo')

    def __str__(self):
        return self.titulo
```

O código mostra três alterações principais: a inclusão da classe `Meta`, um novo campo `titulo` e o método `__str__()`. A classe `Meta` é utilizada pelo Django admin para configurar a interface administrativa. Já percebeu que a palavra "Noticia" está aparecendo sem o acento agudo? Então, para corrigir isso a classe `Meta` possui dois atributos:

* `verbose_name`: determina o nome literal do model no singular
* `verbose_name_plural`: determina o nome literal do model no plural

O campo `titulo` é do tipo `CharField` e a instanciação fornece mais parâmetros: 

* `"Título"`, o primeiro parâmetro, determina o nome literal do campo
* `max_length` determina o tamanho máximo para um valor neste campo (no caso, `128`)

A diferença entre os tipos `CharField` e `TextField` é que o primeiro é utilizado para representar uma string de uma linha, enquanto o segundo é utilizado para representar uma string com múltiplas linhas. Na interface gráfica do formulário de cadastro do model no Django admin o `TextField` é apresentado como um elemento `textarea`, enquanto o `CharField` é apresentado como um `input` com `type="text"`. 

O campo `conteudo` também passa a ter um nome literal (primeiro parâmetro do construtor de `TextField`).

O método `__str__()` é utilizado para criar uma representação de string de um registro. O conteúdo do código indica, portanto, que a representação string do registro é o valor do campo `titulo`.

Para atualizar o banco de dados é preciso repetir o processo anterior: criar migration, aplicar migration. Entretanto, como já existe um banco de dados, a modificação no model pode gerar erros na sua estrutura. Para não ter problemas agora exclua os arquivos `db.sqlite3` e `app_noticias/migrations/0001_initial.py`.

Execute os comandos a seguir para criar a migration, aplicá-la e criar o super usuário:

```{style=nonumber .sh}
$ python manage.py makemigrations
$ python manage.py migrate
$ python manage.py createsuperuser
```

Inicie o servidor web local e veja como o Django admin se comporta.

## Personalizando o site

O Django chama de "site" a área do software que não utiliza o Django admin. Até o momento a página inicial do site mostra a página padrão do Django, como você já sabe. Vamos modificar isso para que a página inicial apresente a lista das notícias.

### Criando a HomePageView

As seções anteriores mostraram como trabalhar com o **Model**. Agora é o momento de trabalhar com a **View**. Para isso, modifique o arquivo `app_noticias/views.py` para o seguinte conteúdo:

```{#lst:app_noticias_views .python caption="Código inicial para as views do software Notícias"}
from django.shortcuts import render
from django.views.generic import ListView

from .models import Noticia

class HomePageView(ListView):
    model = Noticia
    template_name = 'app_noticias/home.html'
```

O [@lst:app_noticias_views] demonstra a importação da classe `ListView`, fornecida pelo pacote `django.views.generic` e da classe `Noticia`, que está no arquivo `models.py` (linha 5). Além disso, demonstra o conteúdo da classe `HomePageView`, que herda de `ListView` e é utilizada para representar uma **class based view** (view baseada em classe). A classe possui dois atributos importantes:

* `model`: indica o model utilizado na view (nesse caso, o model `Noticia`)
* `template_name`: indica o caminho do **template** utilizado na view

Quando o Django identifica que é necessário apresentar uma View do tipo `ListView` ele inicia um procedimento que passa pela identificação do model e do template. Identificar o model é necessário para saber quais dados devem ser obtidos (nesse caso, uma lista de notícias) e identificar o template para saber como, efetivamente, gerar o HTML que será fornecido como resposta para o browser.


### Templates

Um **Template** é outro elemento importante do Django. Sua responsabilidade é, efetivamente, criar a interface gráfica de uma View. Embora o nome "view" dê a entender que a própria classe `HomePageView` teria também a descrição da interface gráfica, a maneira mais usual é associar um Template a uma view e a classe a um Controller. Nesse caso o template utilizado está em `app_noticias/templates/app_noticias/home.html`. Qual a razão desse caminho e por que na classe o valor de `template_name` é apenas `'app_noticias/home.html'`?

O Django determina uma estrutura padrão para o projeto e, em relação a templates de aplicativos Django, eles devem estar em uma pasta `templates` dentro do aplicativo. Além disso, os templates devem estar em outra pasta com o nome do aplicativo. Isso explica o caminho do arquivo do template.

Entretanto, na hora de informar para a view qual template utilizar deve-se informar apenas o caminho depois de `app_noticias/templates/`, por isso `app_noticias/home.html`. Veja o conteúdo desse arquivo:

```{#lst:app_noticias_template_home .html caption="Código inicial para o template \"home\" do software Notícias"}
<h1>Notícias</h1>
{% for noticia in object_list %}
<div>
    <h2>{{ noticia.titulo }}</h2>
    <p>{{ noticia.conteudo | linebreaksbr }}</p>
    <br>
</div>
{% endfor %}
```

O [@lst:app_noticias_template_home] mostra que o conteúdo do template é uma mistura de **HTML** com outra notação. Essa notação, chamada de **linguagem de template do Django** (ou DTL, de *Django Template Language*), usa a **engine** de template padrão do Django, chamada **DjangoTemplates**. Perceba que essa notação tem alguns elementos importantes:

* **tags**: código que está entre `{%` e `%}` 
* **variáveis**: código que está entre `{{` e `}}`
* **filtros**: modifica a saída de uma variável e utiliza o símbolo "pipe" (`|`)

Uma **tag** permite, por exemplo, controle de fluxo. No [@lst:app_noticias_template_home] a tag `for` cria um bloco de repetição, cujo conteúdo está entre as linhas 4 e 8, e é finalizado pela tag `endfor` (da linha 9). A sintaxe é:

```{style=nonumber}
{% for objeto in lista %}
... conteudo do bloco ...
{% endfor %}
```

O template possui a variável `object_list`, que representa a lista de notícias cadastradas (isso é informado pela  `HomePageView`). Assim, o conteúdo do bloco é repetido para cada elemento de `object_list`, ou seja, o objeto `noticia`. 

O conteúdo do bloco utiliza a sintaxe de variável para apresentar o título (linha 5) e o conteúdo da notícia (linha 6). Em especial, a linha 6 utiliza o filtro `linebreaksbr`, que é utilizado para converter quebras de linha em elementos `<br>` do HTML.

### URLs

Embora o software tenha a `HomePageView` e seu template, é necessário informar ao Django como chegar até essa view, definindo URLs do aplicativo `app_noticias`. Para isso, crie o arquivo `app_noticias/urls.py` com o seguinte conteúdo:


```{#lst:app_noticias_urls .python caption="Código inicial para as URLs do aplicativo Notícias"}
from django.urls import path
from . import views

urlpatterns = [
    path('', views.HomePageView.as_view(), name='home'),
]
```

Primeiro, o [@lst:app_noticias_urls] importa as views definidas no aplicativo (linha 2), depois, cria a variável `urlpatterns`, uma lista com definições de URLs. Cada item da lista é criado por meio da função `path()`. Os parâmetros da função são:

* caminho, neste caso `''` representa a raiz
* view, neste caso `views.HomePageView.as_view()`
* nome da URL, neste caso `home`

Cada view do aplicativo `app_noticias` deve ter um caminho registrado no seu arquivo `urls.py`.

Por fim, é necessário incluir as URLs do `app_noticias` no `projeto_noticias`. Para isso, modifique o arquivo `projeto_noticias/urls.py` para que tenha o conteúdo a seguir.

```{#lst:projeto_noticias_urls .python caption="URLs do projeto Notícias"}
...
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('app_noticias.urls'))
]
```

O [@lst:projeto_noticias_urls] começa incluindo a função `include()` (do pacote `django.urls`) e, na definição da variável `urlpattenrs`, declara um novo caminho (linha 7) que é responsável por incluir as URLs do `app_noticias` no caminho raiz. Dessa forma, ao acessar `http://127.0.0.1:8000/` o Django fornecerá a view `HomePageView` (ou `home`) definida no `app_noticia`. Acesse o software no browser. O resultado deverá ser semelhante ao ilustrado pela [@fig:10-app-noticias-home].

![Tela inicial do software Notícias](./graphics/10-app-noticias-home.png){#fig:10-app-noticias-home}

A [@fig:10-app-noticias-home] ilustra a tela inicial do software apresentando as notícias cadastradas. 

## Fazendo deploy no Heroku

Seguindo o *workflow* o próximo passo é configurar o repositório local do Git e fazer o deploy no Heroku. Essa etapa fica como exercício. Se tiver dúvidas, volte para [@sec:introducao].

## Ciclo do app no Heroku e o banco de dados SQLite

Até agora estamos utilizando o banco de dados SQLite. Já comentei que ele é mais útil no ambiente de desenvolvimento do que na produção e, no caso do Heroku, há uma razão que justifica essa afirmação. Os **dynos**, as unidades de execução do aplicativo no Heroku, são controlados pela estrutura de **PaaS**, o que significa que eles podem ser reiniciados de tempos em tempos e, até mesmo, são reiniciados toda vez que você faz um deploy. 

Esse comportamento faz com que o arquivo do banco de dados SQLite seja sobrescrito toda vez que os **dynos** são iniciados. Então, se você testar seu software durante algum tempo, pode perceber que dados foram perdidos. Isso não é o comportamento adequado para a produção mas, por enquanto, não vamos resolver esse problema. Fica para outros capítulos. Aguenta aí.

## Testes

Lembra que comentei no Capítulo [-@sec:introducao] que no *workflow* é muito bom garantir que o software esteja funcionando corretamente antes de fazer o deploy? Então, essa seção apresenta uma forma sistemática de garantir isso. 

Quando é necessário verificar que um software está funcionando como esperado, geralmente são conduzidos **testes unitários**, que verificam, por exemplo, se a lógica do acesso ou gerenciamento dos  dados (Model) está funcionando. Para conduzir esse tipo de teste o Django fornece recursos como a classe `TestCase` (pacote `django.test`). 

Para escrever testes deve-se herdar da classe `django.test.TestCase` e declarar um ou mais métodos cujos nomes comecem com `test`. Para exemplificar crie um teste para verificar se os models estão funcionando, se é possível criar e recuperar um registro, por exemplo. Para isso, crie o arquivo `app_noticias/tests.py` com o seguinte conteúdo:

```{.python}
from django.test import TestCase
from .models import Noticia

class NoticiaModelTest(TestCase):
    def setUp(self):
        Noticia.objects.create(titulo='Noticia X', conteudo='Conteudo')

    def test_deve_encontrar_noticia_x(self):
        noticia = Noticia.objects.get(titulo='Noticia X')
        self.assertEqual(noticia.titulo, 'Noticia X')

    def test_deve_encontrar_noticia_com_id_1(self):
        noticia = Noticia.objects.get(id=1)
        self.assertEqual(noticia.id, 1)

    def test_deve_gerar_excecao_para_encontrar_noticia_com_id_2(self):
        with self.assertRaisesMessage(Noticia.DoesNotExist, 'Noticia matching query does not exist'):
            noticia = Noticia.objects.get(id=2)
```

Perceba que a classe `NoticiaModelTest` herda de `TestCase` e tem quatro métodos:

* `setUp()`: executado pelo Django antes do primeiro teste. Nesse caso (linha 6) cadastra uma notícia
* `test_deve_encontrar_noticia_x()`: testa positivo para encontrar uma notícia cujo título é "Noticia X"
* `test_deve_encontrar_noticia_com_id_1()`: testa positivo para encontrar uma notícia cujo atributo `id` é igual a `1`
* `test_deve_gerar_execaco_para_encontrar_noticia_com_id_2()`: testa positivo para gerar uma exceção ao tentar encontrar uma notícia cujo atributo `id` tenha valor `2`

Quando o software utiliza um banco de dados o Django cria automaticamente um banco de dados para teste. Então, não se preocupe com seu banco de dados de desenvolvimento ou de produção.

A classe `NoticiaModelTest` é chamada também de **suíte de testes** (contém vários testes). O Django executa cada teste na ordem em que são encontrados. Os nomes dos testes são realmente longos, mas a expectativa é que sejam autoexplicativos. Vamos analisar cada teste. 

O `test_deve_encontrar_noticia_x()` realiza uma consulta no model `Noticia` buscando uma notícia com atributo `titulo` igual a `'Noticia X'` (linha 9). Na sequência usa o método `assertEqual()` para realizar uma **asserção**. 

Uma asserção é uma comparação entre um valor esperado e um valor obtido. Por exemplo, considere que o valor esperado seja 1, se o valor obtido for igual a 1, então a asserção **passa**, se o valor obtido for igual a 2, então a asserção **falha**. Um teste pode ver mais de uma asserção. Um teste passa se todas as suas asserções também passam. Um teste falha se uma de suas asserções falha.

Como o método `setUp()` criou uma notícia com o título `'Noticia X'`, é esperado que realmente haja uma notícia cadastrada com atributo `titulo` igual a `'Noticia X'`, ou seja, é esperado que o teste passe.

O `test_deve_encontrar_noticia_com_id_1()` realiza uma consulta no model `Noticia` buscando uma notícia com atributo `id` igual a `1`.

O `test_deve_gerar_excecao_para_encontrar_noticia_com_id_2()` usa um contexto criado pelo método `assertRaisesMessage()` para gerar com a expectativa de gerar uma exceção do tipo `Noticia.DoesNotExist` ao tentar encontrar um notícia com atributo `id` igual a `2`.

Use o comando a seguir para executar os testes:

```{style=nonumber .sh}
$ python manage.py test
```

A saída vai ser parecida com o seguinte:

```{style=nonumber}
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
...
----------------------------------------------------------------------
Ran 3 tests in 0.004s

OK
Destroying test database for alias 'default'...
```

É importante interpretar essa saída:

* foram executados 3 testes (`Ran 3 tests`)
* os testes executaram em um tempo total de 0.004 segundos (`in 0.004s`)
* todos os testes passaram (`OK`)

Para gerar uma falha proposital nos testes, modifique o `test_deve_encontrar_noticia_com_id_1()` e altere a asserção para `self.assertEqual(noticia.id, 2)`. Claro, você já sabe que o teste vai falhar, mas faça isso mesmo assim para entender o que muda na saída. Seria mais ou menos assim:

```{style=nonumber}
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
F..
======================================================================
FAIL: test_deve_encontrar_noticia_com_id_1 (app_noticias.tests.NoticiaModelTest)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/mnt/d/Developer/djangobook-noticias/app_noticias/tests.py", line 17, in test_deve_encontrar_noticia_com_id_1
    self.assertEqual(noticia.id, 2)
AssertionError: 1 != 2

----------------------------------------------------------------------
Ran 3 tests in 0.005s

FAILED (failures=1)
Destroying test database for alias 'default'...
```

Interpretando a saída temos:

* o teste `test_deve_encontrar_noticia_com_id_1` falhou porque esperava que 1 fosse igual a 2 (o que não é verdade)
* foram executados 3 testes, em 0.005 segundos
* a suíte de testes falhou (`FAILED`)
* 1 de 3 testes falharam

Enquanto a suíte `NoticiaModelTest` testa o Model, também é possível escrever teste para testar a View, veja o trecho de código a seguir, que mostra a classe `HomePageViewTest`, também declarada no arquivo `app_noticias/tests.py`:

```{.python}
from django.test import TestCase
from django.urls import reverse

class HomePageViewTests(TestCase):
    def setUp(self):
        Noticia.objects.create(titulo='Noticia X', conteudo='Conteudo')

    def test_home_status_code_deve_ser_200(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)

    def test_deve_encontrar_url_por_nome(self):
        response = self.client.get(reverse('home'))
        self.assertEqual(response.status_code, 200)

    def test_view_deve_usar_template_correto(self):
        response = self.client.get(reverse('home'))
        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, 'app_noticias/home.html')
```

Essa suíte possui três testes:

* `test_home_status_code_deve_ser_200()`: testa positivo para o código de retorno de uma requisição para a view ser 200
* `test_deve_encontrar_url_por_nome()`: testa positivo para o código de retorno de uma requisição para a URL chamada `"home"` ser 200
* `test_view_deve_usar_template_correto()`: testa positivo para o código de retorno de uma requisição para a URL chamada `"home"` ser 200 e o template usado na view ser `app_noticias/home.html`

Como esses são testes para a View eles utilizam o método `get()` do objeto `client` para fazer uma requisição HTTP GET para uma URL. No `test_home_status_code_deve_ser_200` é feita uma requisição GET para a URL `/`, ou seja a raiz do software. No `test_deve_encontrar_url_por_nome` primeiro é obtida a URL a partir do nome, usando a função `reverse()`, do pacote `django.urls`, depois é feita uma requisição para a URL encontrada. Além disso, os testes demonstram o foco no teste do código de status da resposta (HTTP). Quando o código de status é 200 significa que foi possível fazer a requisição de forma correta.

O último teste da suíte usa o método `assertTemplateUsed()` para fazer uma asserção de que o template usado na view seja o esperado.

Ao executar os testes completos, com as duas suítes, o resultado é como apresentado a seguir:

```{style=nonumber}
Creating test database for alias 'default'...
System check identified no issues (0 silenced).
......
----------------------------------------------------------------------
Ran 6 tests in 0.043s

OK
Destroying test database for alias 'default'...
```

Ou seja:

* foram executados 6 testes, em 0.043 segundos
* todos os testes passaram

Também é possível aumentar o detalhamento da saída dos testes utilizando a opção `-v 2`, por exemplo:

```{style=nonumber .sh}
$ python manage.py test -v 2
```

A saída seria mais ou menos assim:

```{style=nonumber}
Creating test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
Operations to perform:
  Synchronize unmigrated apps: messages, staticfiles
  Apply all migrations: admin, app_noticias, auth, contenttypes, sessions
Synchronizing apps without migrations:
  Creating tables...
    Running deferred SQL...
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  Applying admin.0001_initial... OK
  Applying admin.0002_logentry_remove_auto_add... OK
  Applying app_noticias.0001_initial... OK
  Applying contenttypes.0002_remove_content_type_name... OK
  Applying auth.0002_alter_permission_name_max_length... OK
  Applying auth.0003_alter_user_email_max_length... OK
  Applying auth.0004_alter_user_username_opts... OK
  Applying auth.0005_alter_user_last_login_null... OK
  Applying auth.0006_require_contenttypes_0002... OK
  Applying auth.0007_alter_validators_add_error_messages... OK
  Applying auth.0008_alter_user_username_max_length... OK
  Applying auth.0009_alter_user_last_name_max_length... OK
  Applying sessions.0001_initial... OK
System check identified no issues (0 silenced).
test_deve_encontrar_url_por_nome (app_noticias.tests.HomePageViewTests) ... ok
test_home_status_code_deve_ser_200 (app_noticias.tests.HomePageViewTests) ... ok
test_view_deve_usar_template_correto (app_noticias.tests.HomePageViewTests) ... ok
test_deve_encontrar_noticia_com_id_1 (app_noticias.tests.NoticiaModelTest) ... ok
test_deve_encontrar_noticia_x (app_noticias.tests.NoticiaModelTest) ... ok
test_deve_gerar_excecao_para_encontrar_noticia_com_id_2 (app_noticias.tests.NoticiaModelTest) ... ok

----------------------------------------------------------------------
Ran 6 tests in 0.032s

OK
Destroying test database for alias 'default' ('file:memorydb_default?mode=memory&cache=shared')...
```

Perceba que a saída mostra mais informações, como a execução das migrations para a criação do banco de dados e o resultado individual de cada teste.


## Conclusão

A estrutura do projeto começa a aumentar bastante à medida que vão sendo adicionadas funcionalidades no projeto e no aplicativo Django, como ilustra a [@fig:estrutura-noticias-completo]. 

\begin{landscape}
    \begin{figure}[ht]
        \centering
        \includegraphics[width=23cm]{./graphics/11-estrutura-noticias-completo.eps}
        \caption{Tela da lista de notícias apresentando registros}
        \label{fig:estrutura-noticias-completo}
    \end{figure}   
\end{landscape}


A [@fig:estrutura-noticias-completo] apresenta uma visão do projeto e suas dependências com classes do Django, bem como a sua complexidade, que, novamente, tende a aumentar conforme vão sendo adicionados recursos e funcionalidades. O importante é identificar que essa é a estrutura padrão de um aplicativo Django, que os capítulos seguintes continuarão apresentando de forma mais detalhada, apresentando novos recursos e conceitos. Além disso a figura procura apresentar uma visão mais estruturada dos elementos do projeto (pacotes e classes) ao invés de somente arquivos.

A [@fig:workflow-com-testes] apresenta uma alteração no *workflow* incluindo a criação de um aplicativo Django e a etapa de testes.

```{#fig:workflow-com-testes .plantuml caption="Workflow para o desenvolvimento com Testes" format="eps"}
@startuml
start
if (tem que criar o projeto?) then (sim)
    :Criar pasta do projeto e \ncontinuar a partir dela;
    :Ativar o ambiente do projeto;
    :Instalar o pacote **django**;
    :Criar um projeto Django\n""django-admin startproject projeto ."";
elseif (tem app para criar?) then (sim)
    :Criar app\n""python manage.py startapp app"";
    :Configurar o **settings.py**;
elseif (tem que configurar o Git?) then (sim)
    :Iniciar o repositório Git local\n""git init"";
    :Definir as informações do usuário\n""git config"";
elseif (tem que configurar o Heroku?) then (sim)
    :Fazer login\n""heroku login"";
    :Criar o arquivo **Procfile**;
    :Instalar o pacote **gunicorn**;
    :Alterar **ALLOW_HOSTS** no\n arquivo **settings.py**;
    :Criar o app no Heroku\n""heroku create"";
    :Conectar os repositórios\nGit local e remoto\n""heroku git:remote -a"";
    :Configurar Heroku para\nignorar arquivos estáticos\n""heroku config:set"";
endif
repeat 
    if (precisa de model?) then (sim)
        :Criar model no arquivo **models.py**;
        :Criar migration(s)\n""python manage.py makemigrations"";
        :Executar migration(s)\n""python manage.py migrate"";
    elseif (vai usar o Django admin?) then (sim)
        :Configurar o **admin.py**;
    elseif (precisa de testes?) then (sim)
        :Escrever testes;
        :Executar testes\n""python manage.py test"";
        if (testes passaram?) then (sim)
            :Adicionar alterações para no próximo commit\n""git config add ."";
            :Fazer o commit\n""git commit"";
            :Fazer push para o remoto\n""git push heroku master"";
        else (não)
            :Identificar correções;
            :Realizar correções;
        endif
    endif
repeat while (tem mais coisas para fazer?) then (sim)
if (tem que iniciar aplicativo no Heroku?) then (sim)
    :Iniciar o aplicativo no Heroku\n""heroku ps:scale web=1"";
endif
stop
@enduml
```

