# Acesso público: views e templates 

Agora que o `app_noticias` tem uma interface administrativa que permite um gerenciamento dos dados mais completo podemos incrementar o acesso público, permitindo funcionalidades para leitura das notícias. 

Você já sabe que o Django é um framework **MVC** (Model-View-Controller) onde **model** representa o modelo de dados, **view** representa interface gráfica e **controller** contém a lógica de negócio. Entretanto, os componentes do Django são traduzidos para **MTV** (**Model-Template-View**) ou seja, o **template** representa a interface gráfica, enquanto a **view** contém a lógica. Essa distinção é importante. Além disso, é importante entender que o Django utiliza URLs para indicar como views devem ser acessadas. Esse capítulo apresenta esses conceitos.

Views podem ser descritas de duas formas: usando funções ou usando classes. Independentemente da forma de descrever as views é necessário utilizar URLs para acessá-las. As seções a seguir detalham as formas de descrever as views.

## Views baseadas em funções

As views descritas por funções são as mais simples de escrever. Para exemplificar, considere uma view que apresenta um sumário (resumo) com a quantidade total de notícias:

```python
from django.http import HttpResponse
from .models import Noticia

def noticias_resumo(request):
    total = Noticia.objects.count()
    html = """
    <html>
    <body>
    <h1>Resumo</h1>
    <p>A quantiade total de notícias é {}.</p>
    </body>
    </html>
    """.format(total)
    return HttpResponse(html)
```

A função `noticias_resumo()` recebe o parâmetro `request`, obrigatório como primeiro parâmetro de toda view definida por função.

A variável `total` recebe o resultado de `Noticia.objects.count()` (o total de instâncias do model `Noticia`).

A variável `html` é uma string que contém elementos (tags) do HTML, mas foi definida manualmente e diretamente no código python. Embora isso não esteja totalmente errado, você já deve perceber que não é uma boa prática fazer isso com uma página longa. Voltaremos nisso daqui a pouco.

O retorno da função `noticias_resumo()` é uma instância de `HttpResponse()` que recebe como argumento a variável `html`. 


## Configurações de URLs (acessando views)

Para acessar a view é necessário configurar as URLs do aplicativo, ou seja, o módulo `app_noticias.urls`:

```python
from django.urls import path
from app_noticias.views import noticias_resumo, HomePageView

urlpatterns = [
    path('', HomePageView.as_view(), name='home'),
    path('noticias/resumo/', noticias_resumo, name='resumo'),
]
```

A variável `urlpatterns` é uma lista de instâncias de `django.urls.path()` ou `django.urls.re_path()`. Durante o processamento da requisição o Django começa a procurar nas URLs do aplicativo aquela que mais combina com a URL da requisição e, quando a encontra, identifica qual view deve ser importada e chamada. No momento de chamar a view, o Django passa os seguintes argumentos:

* uma instância de `HttpRequest`
* parâmetros de rota e valores-padrão (se definidos) -- isso será visto mais adiante

O construtor de `path()` recebe os parâmetros:

* **caminho** (ou **rota**): uma string que representa o caminho da URL
* view
* outros parâmetros nomeados, como `name`, que indica o nome da URL

**Importante**: como estamos definindo as URLs em um aplicativo é fundamental que o projeto as importe corretamente. Para isso, verifique o módulo `projeto_noticias.urls`:

```python
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('app_noticias.urls'))
]
```

O segundo elemento do array `urlpatterns` é uma chamada para `path()` com os parâmetros:

* `''`: indicando a **raiz do site**
* uma chamada à função `include()` passando como argumento `'app_noticias.urls'`, a string que indica as URLs do `app_noticias`

Assim, se a requisição for para a URL `/` o Django fará a busca pelas URLs na sequência:

* em `urlpatterns` de `projeto_noticias.urls` (não encontra, continua procurando)
* em `urlpatterns` de `app_noticias.urls` (encontra a URL `home` para a view `HomePageView`)

Se a requisição for para a URL `/noticias/resumo/` a busca será feita na sequência:

* em `urlpatterns` de `projeto_noticias.urls` (não encontra, continua procurando)
* em `urlpatterns` de `app_noticias.urls` (encontra a URL `resumo` para a view `noticias_resumo`)

Se a requisição for para a URL `/noticias/teste/` a busca será feita na sequência:

* em `urlpatterns` de `projeto_noticias.urls` (não encontra, continua procurando)
* em `urlpatterns` de `app_noticias.urls` (não encontra, continua procurando)
* não tem mais onde procurar, retorna erro 404 (página não encontrada)


## Templates

A view `noticias_resumo()`, embora funcione, não é muito eficiente do ponto-de-vista de código e boas práticas Django porque ela define código HTML dentro de strings no código Python. Uma maneira de separar isso, mantendo código separado, é utilizar templates. Para exemplificar, veja a view `noticias_resumo_template()`:

```python
from django.shortcuts import render
def noticias_resumo_template(request):
    total = Noticia.objects.count()
    return render(request, 'app_noticias/resumo.html', {'total': total})
```

A view `noticias_resumo_template()` é semelhante à `noticias_resumo()`, mas retorna uma instância de `render()`, um atalho para `HttpResponse` que aceita os parâmetros:

* uma instância de `HttpRequest`
* o caminho para o template
* um dicionário de valores a serem adicionados ao *contexto do template*

O *contexto do template* contém alguns objetos ou valores disponibilizados automaticamente pelo Django no template. No caso da função `render()` o dicionário de valores **permite passar valores da view para o template**.

O código-fonte do template para apresentar o resumo das notícias (`app_noticias/templates/app_noticias/resumo.html`):

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Resumo das notícias</title>
</head>
<body>
<h1>Resumo das notícias</h1>
<p>Quantidade de notícias: {{ total }}.</p>
</body>
</html>
```

Perceba que a view `noticias_resumo_template()` definiu um dicionário com a chave `total` para ser fornecido ao template. Por isso o template pode usar a variável de template `total`.

## Views e URLs com parâmetros

Suponha que a página inicial (`home`) do `app_noticias` apresente uma lista com títulos das notícias recentes e cada item da lista seja um link para uma página que permita ler o conteúdo da notícia (bem como ver outras informações, como autor, data e tags). Uma forma de permitir ler uma notícia específica, digamos por meio do seu identificador, é utilizar uma URL com parâmetro. Primeiro, a view `noticia_detalhes()`:

```python
from django.http import Http404
from django.shortcuts import render
from .models import Noticia

def noticia_detalhes(request, noticia_id):
    try:
        noticia = Noticia.objects.get(pk=noticia_id)
    except Noticia.DoesNotExist:
        raise Http404('Notícia não encontrada')
    return render(request, 'app_noticias/detalhes.html', {'noticia': noticia})
```

Como você já sabe, a view `noticia_detalhes()` deve ter o primeiro parâmetro `request`. O segundo parâmetro `noticia_id` é novidade (voltaremos nele daqui a pouco). Por enquanto, assuma que `noticia_id` contém o identificador da notícia que deve ser apresentada. Assim, a primeira tarefa é encontrar a instância de `Noticia`. Para isso o código utiliza `try...except`: tenta encontrar a notícia utilizando `Noticia.objects.get(pk=noticia_id)`; se não encontrar (`except` do tipo `Noticia.DoesNotExist`) dispara uma exceção criada por `Http404` (uma página de erro indicando que a notícia indicada por `noticia_id` não foi encontrada); se encontrar, retorna um `HttpResponse` utilizando como template `app_noticias/detalhes.html`.

O código-fonte do template:

```html
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>{{ noticia.titulo }}</title>
</head>
<body>
<h1>{{ noticia.titulo }}</h1>
<p>Por <strong>{{ noticia.autor }}</strong> em {{ noticia.data_de_publicacao }}</p>
<p>Tags:
    {% for tag in noticia.tags.all %}
        <a href="{% url "noticias_da_tag" tag.slug %}">{{ tag }}</a>{% if not forloop.last %}, {% endif %}
    {% endfor %}
</p>
<div>
    {{ noticia.conteudo | linebreaks }}
</div>

</body>
</html>
```

O template apresenta as informações da notícia, como título, autor, data de publicação, tags e conteúdo. Atenção especial para a apresentação das tags da notícia. O model `Noticia` define um relacionamento **muitos-para-muitos** com `Tag` por meio do campo `tags`. Para obter a lista das tags da notícia é necessário utilizar `noticia.tags.all` na tag `for`. 

Agora, a configuração da URL:

```python
from django.urls import path
from app_noticias.views import noticia_detalhes

urlpatterns = [
    # ...
    path('noticias/<int:noticia_id>/', noticia_detalhes, name='detalhes'),
    # ...
]
```

A URL `detalhes` contém o caminho: `noticias/<int:noticia_id>/`. A parte entre `<>` representa a definição do **parâmetro de rota** chamado `noticia_id` e a parte `int:` é um conversor de caminho, o que significa que o parâmetro de rota será tratado como um número inteiro positivo. Outros conversores de caminho são: `str`, `slug`, `uuid` e `path`. O nome do parâmetro de rota `noticia_id` ser o mesmo do parâmetro `noticia_id` da view `noticia_detalhes()` não é por acaso. 

Suponha que o Django trate uma requisição para a URL `/noticias/1/`. O processamento da URL ocorre nesta sequência:

* procura em `urlpatterns` de `projeto_noticias.urls` (não encontra, continua procurando)
* procura em `urlpatterns` de `app_noticias.urls` (encontra a URL `detalhes` para a view `noticia_detalhes` e extrai o parâmetro de rota `noticias_id` com valor `1` (um número inteiro positivo))
* executa a view `noticia_detalhes`

Está curioso para saber o que acontece se a URL for `/noticias/a/`? Esta seria a sequência:

* procura em `urlpatterns` de `projeto_noticias.urls` (não encontra, continua procurando)
* procura em `urlpatterns` de `app_noticias.urls` (não encontra, continua procurando)
* não tem mais onde procurar, retorna erro 404 (página não encontrada)

Por que ocorreu o erro 404? Porque mesmo com uma URL com um padrão de caminho semelhante o parâmetro `noticia_id` deve ser tratado como um número inteiro positivo. Não é o caso aqui.

O que acontece se a URL for `/noticias/2/` (supondo que não exista uma notícia com identificador igual a `2`)? Esta seria a sequência:

* procura em `urlpatterns` de `projeto_noticias.urls` (não encontra, continua procurando)
* procura em `urlpatterns` de `app_noticias.urls` (encontra a URL `detalhes` para a view `noticia_detalhes` e extrai o parâmetro de rota `noticias_id` com valor `2` (um número inteiro positivo))
* executa o código da view `noticias_detalhes` e, como não encontra a notícia com `pk` igual a `2`, gera uma página de erro 404, indicando que a notícia em questão não foi encontrada

Há uma diferença sutil, mas muito importante na forma como o Django executa o processamento dessas requisições.

## Gerando URLs nos templates

A URL `detalhes` tem o parâmetro de rota `noticia_id` (um inteiro positivo). Gerar um elemento `a` (link) para a página de detalhe de uma notícia específica deve ser bastante simples, certo? Sim e não. Sim porque é, a princípio, uma tarefa simples, mas não porque a maior complicação é não saber onde o software estará disponível. Aqui entra em ação o nome da URL. Veja um trecho do template da URL `home`:

```html
<h2>Notícias recentes</h2>
{% for noticia in object_list %}
<div>
    <div><a href="{% url "detalhes" noticia.pk %}">{{ noticia.titulo }}</a></div>
</div>
{% endfor %}
```

O atributo `href` do `a` que representa o link para a página de detalhes da notícia é gerado pela tag `url` do Django, que recebe dois parâmetros:

* o nome da URL (`'detalhes'`)
* o identificador da notícia (`noticia.pk`)

Isso faz com que seja gerada uma saída para o browser semelhante à seguinte:

```html
<div>
<a href="/noticias/1/">...</a>
</div>
```

Perceba que o atributo `href` tem um valor gerado especificamente para situação da execução do software no momento (ele está hospedado na raiz `/`, por exemplo).

---

**Utilização de conversores de caminho**

Embora os exemplos deste capítulo tenham demonstrado a utilização de **conversor de caminho** isso não é sempre necessário. Por exemplo, a rota da URL `detalhes` poderia ser `noticias/<noticia_id>/`, sem utilizar um conversor de caminho. Isso modificaria o processamento da URL `/noticias/a/`.

---

## Views baseadas em classes

As views baseadas em classes são um mecanismo mais complexo do Django para descrever views e grande parte dessa complexidade se deve ao fato da hierarquia de tipos de views, que começa com a classe `View`.

### `View`

Implementar uma view baseada em classe significa criar uma classe que usa uma das classes da hierarquia que começa com `View` e utilizar os métodos específicos para cada situação. Cada classe especializa uma maneira de construir a view. A classe `View` fornece a implementação mais básica. Para alcançar um resultado semelhante ao obtido anteriormente com views baseadas em funções poderíamos implementar a classe `NoticiasResumoView` da seguinte forma:

```python
from django.views import View
from django.shortcuts import render
from .models import Noticia

class NoticiasResumoView(View):
    template_name = 'app_noticias/resumo.html'

    def get(self, request, *args, **kwargs):
        total = Noticia.objects.count()
        return render(request, self.template_name, {'total': total})
```

O método `get()` da classe `NoticiasResumoView` atende requisições HTTP com o verbo GET e, da mesma forma, há métodos para atender requisições de outros verbos do HTTP, como POST e HEAD. O método `get()` retorna o valor do método `render()` que, como já vimos, é um objeto  `HttpResponse`.

A classe também possui um atributo de classe chamado `template_name`, que contém o nome do template. Se você está se perguntando: não, não tem nada de obrigatório ou especial com esse nome; é apenas o nome do atributo de classe. Perceba a semelhança com a view baseada em função `noticias_resumo_template()`.

A configuração da URL passa por uma pequena mudança:

```python
from django.urls import path
from app_noticias.views import NoticiasResumoView

urlpatterns = [
    # ...
    path('noticias/resumo/', NoticiasResumoView.as_view(), name='resumo'),
    # ...
]
```

O segundo argumento para a função `path()`, ao invés de ser o nome da função, é o retorno do método de classe `as_view()`. Essa é a forma padrão de configurar a URL para toda classe que herda de `View`.


### `TemplateView`

A classe `TemplateView` implementa uma view que *renderiza* um template e pode ter contexto capturado da URL. Essa classe herda de:

* `django.views.generic.base.TemplateResponseMixin` que fornece, principalmente, o atributo de classe `template_name`
* `django.views.generic.base.ContextMixin` que fornece, principalmente, o método `get_context_data()` e o atributo de classe `extra_context`
* `django.views.generic.base.View`

A seguir, o código-fonte da classe `NoticiasResumoView` modificada para herdar de `TemplateView`:

```python
from django.views.generic import TemplateView
from .models import Noticia
from django.shortcuts import render

class NoticiasResumoView(TemplateView):
    template_name = 'app_noticias/resumo.html'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['total'] = Noticia.objects.count()
        return context
```

O atributo de classe `template_name` contém o caminho para o template. O método `get_context_data()` é uma sobrescrita do método da superclasse e define o contexto do template com a chave `total` (que contém a quantidade total de notícias).

O *contexto do template* é um dicionário passado para template e serve como uma forma de transportar dados da view para o template. No exemplo de código, o contexto contém a chave `total` e a torna disponível para ser utilizada no template.

As classes `View` e `TemplateView` são consideradas pelo Django como **classes base** por fornecerem as implementações de recursos mais fundamentais de views. Entretanto, o Django também fornece implementações de tarefas mais corriqueiras, como views que acessam model. 

O Django categoriza as views da seguinte forma:

* views base
    * `View`
    * `TemplateView`
    * `RedirectView`
* views genéricas de visualização
    * `DetailView`
    * `ListView`
* views genéricas de edição
    * `FormView`
    * `CreateView`
    * `UpdateView`
    * `DeleteView`
* views genéricas de datas
    * `ArchiveIndexView`
    * `YearArchiveView`
    * `MonthArchiveView`
    * `WeekArchiveView`
    * `DayArchiveView`
    * `TodayArchiveView`
    * `DateDetailView`

As seções seguintes apresentam essas views.

### `DetailView`

A classe `DetailView` implementa uma view que está vinculada a um model e apresenta detalhes de uma instância. Mais do que isso, a view possui recursos que tornam sua implementação bastante simples. Vamos utilizar a `DetailView` para implementar a view que mostra os detalhes de uma notícia.

```python
from django.views.generic import DetailView
from .models import Noticia

class NoticiaDetalhesView(DetailView):
    model = Noticia
    template_name = 'app_noticias/detalhes.html'
```

A classe `NoticiaDetalhesView` herda de `DetailView` e possui dois atributos de classe: 

* `model` indica o model associado à view (`Noticia`)
* `template_name` indica o template utilizado (`app_noticias/detalhes.html`)

Um pequeno detalhe está na configuração da URL:

```python
from django.urls import path
from . import views

urlpatterns = [
    # ...
    path('noticias/<int:pk>/', views.NoticiaDetalhesView.as_view(), name='detalhes'),
    # ...
]
```

O parâmetro de rota do caminho da URL passa a se chamar `pk` (porque é o padrão para o nome do parâtro de rota para a `DetailView`). Esse nome não é por acaso. O ORM do Django considera `pk` como um "atalho" para a chave primária do model que, por padrão, é `id`. Então, quando encontra o parâmetro de rota `pk` o Django fará uma busca pelo campo `id`.

A view trata a URL e busca a instância do model no banco de dados, sem a necessidade de implementar esse processo manualmente, como fizemos anteriormente. Isso não é de surpreender, porque a implementação segue um procedimento padrão para qualquer model. Além de buscar a instância pelo parâmetro de rota `pk` outra forma é encontrar pelo campo `slug` (se o model tiver um campo com esse nome).

Não é necessário alterar o template para que o software funcione: o template está baseado na variável `noticia` que é criada automaticamente pela `DetailView` no contexto do template com base no nome do model. Se precisar alterar isso utilize o atributo de classe `context_object_name`. Além de estar disponível no template a instância do model também está disponível na view por meio do atributo de classe `object`.

Geralmente não é necessário alterar mais alguma coisa mas, se precisar, você pode sobreescrever um ou mais destes métodos:

* `get_queryset()`
* `get_object()`
* `get_context_data()`
* `get()`


### `ListView`

A classe `ListView` implementa uma view que está vinculada a um model e apresenta uma lista de instâncias de um model. Vamos revisitar a implementação da classe `HomePageView`, que mostra a lista das notícias recentes, e modificá-la para que mostre apenas as cinco notícias mais recentes que estejam publicadas:

```python
class HomePageView(ListView):
    model = Noticia
    context_object_name = 'noticias'
    template_name = 'app_noticias/home.html'

    def get_queryset(self):
        return Noticia.objects.exclude(data_de_publicacao=None).order_by('-data_de_publicacao')[:5]
```

A classe `HomePageView` herda de `ListView` e possui os atributos de classe:

* `model` indica o model associado à view (`Noticia`)
* `context_object_name` indica o nome da lista de instâncias no contexto do template (`noticias`)
* `template_name` indica o nome do template

Além disso a classe sobrescreve o método `get_queryset()`. Por padrão, a `ListView` retorna todas as instâncias do model. Ao fornecer uma implementação própria o método `get_queryset()` a classe `HomePageView` consegue modificar esse comportamento para retornar apenas as cinco notícias mais recentes (pelo campo `data_de_publicacao`) cujo campo `data_de_publicacao` não seja nulo (igual a `None`) -- isso serviria para garantir, por exemplo, que a notícia esteja publicada.

A lista das instâncias (notícias) está disponível na view por meio do atributo de classe `object_list`.


## Conclusão

Este capítulo apresenta de forma mais detalhada como o Django trabalha com o padrão MVC ou MTV, ao implementar template e view. Além disso, o capítulo mostrou como criar views baseadas em funções e views baseadas em classes, como ligar views e URLs e alguns detalhes sobre a hierarquia de tipos da view começa com a classe `View` e tem também `TemplateView`, `DetailView` e `ListView`.
