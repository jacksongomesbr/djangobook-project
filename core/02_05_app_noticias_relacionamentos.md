# Melhorando o modelo de dados do Aplicativo Notícias {#sec:melhorando-dados-app-noticias}

Este capítulo mostra como melhorar e evoluir o modelo de dados do aplicativo notícias utilizando recursos do model do Django.

Até agora o modelo de dados do `app_noticias` contém apenas o model `Noticia` (e seus atributos `titulo` e `conteudo`). Vamos incrementar esse modelo considerando a seguinte situação:

* notícia está associada a tags: tags são como marcadores atribuídos às notícias pelos autores
* notícia tem um autor: um autor é quem escreve a notícia
* pessoa tem um usuário: o usuário permite que a pessoa acesse o Django Admin para cadastrar notícias

Para alcançar estes objetivos será necessário utilizar o recurso de relacionamentos, como apresentam as seções a seguir.

## Relacionamentos

Da mesma forma que bancos de dados relacionais o ORM do Django permite o recurso de relacionamentos entre models e isso pode ser feito de três formas: **muitos-para-um**, **muitos-para-muitos** e **um-para-um**.

### Relacionamento um-para-um

O relacionamento **um-para-um** é definido utilizando um campo do tipo `django.db.models.OneToOneField`. Na situação apresentada anteriormente, um autor está associado (relacionado) a um usuário. Para fazer isso, primeiro, deve-se considerar que não é necessário criar um model para usuário, mas utilizar `User`, fornecido por `django.contrib.auth.models`. Assim, podemos definir o model `Pessoa` como demostra o trecho de código a seguir:

```python
from django.contrib.auth.models import User
from django.db import models

class Pessoa(models.Model):
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, verbose_name='Usuário')
    nome = models.CharField('Nome', max_length=128)
    data_de_nascimento = models.DateField(
        'Data de nascimento', blank=True, null=True)
    telefone_celular = models.CharField('Telefone celular', max_length=15,
                                        help_text='Número do telefone celular no formato (99) 99999-9999',
                                        null=True, blank=True,
                                        )
    telefone_fixo = models.CharField('Telefone fixo', max_length=14,
                                     help_text='Número do telefone fixo no formato (99) 9999-9999',
                                     null=True, blank=True,
                                     )
    email = models.EmailField('E-mail', null=True, blank=True)

    def __str__(self):
        return self.nome
```

Perceba que o campo `usuario` é do tipo `OneToOneField` e os parâmetros do construtor são, nesta ordem:

* o tipo `User`, para representar o relacionamento **um-para-um**, em si
* `on_delete=models.CASCADE` para indicar que quando a instância de `User` for excluída a instância de `Pessoa` relacionada também deve ser excluída (exclusão em cascata)
* `verbose_name='Usuário'` para definir o nome literal do campo

### Relacionamentos muitos-para-um 

Para definir um relacionamento **muitos-para-um** use a classe `django.db.models.ForeignKey` ao definir seu model. Para exemplificar, considere que muitas `Noticia` possam ser escritas por um autor (ou um autor possa escrever muitas notícias) então teríamos um relacionamento **muitos-para-um** entre o model `Pessoa` e `Noticia` (o código a seguir tem apenas os trecho mais importantes para o contexto):

```python
from django.db import models

class Pessoa(models.Model):
    # ...
    pass


class Noticia(models.Model):
    autor = models.ForeignKey(Pessoa, on_delete=models.CASCADE)
    # ...
```

Dessa forma o model `Noticia` tem um campo `autor` que **referencia** o model `Pessoa`. Os parâmetros do construtor de `ForeignKey` são:

* `Pessoa`, para representar o relacionamento, em si
* `on_delete=models.CASCADE` para definir exclusão em cascata

Outro valor para o parâmetro `on_delete` é `models.SET_NULL`, para atribuir o valor `null` ao campo `autor` quando a instância relacionada for excluída. Nesse caso, o campo precisa aceitar `null` -- com os atributos `null=True` e `blank=True`.


### Relacionamentos muitos-para-muitos

Para definir um relacionamento **muitos-para-muitos** use a classe `django.db.models.ManyToManyField` ao definir seu model. Para exemplificar, considere que `Noticia` tem muitas `Tag` e `Tag` tem muitas `Noticia`:

```python
from django.db import models

class Tag(models.Model):
    nome = models.CharField(max_length=64)
    slug = models.SlugField(max_length=64)

    def __str__(self):
        return self.nome


class Noticia(models.Model):
    # ...
    tags = models.ManyToManyField(Tag)
    # ...
```

O parâmetro para o construtor de `ManyToManyField` é `Tag`, para representar o relacionamento, em si.

Assim, temos os seguintes relacionamentos:

* `Pessoa` **um-para-um** `User`
* `Noticia` **muitos-para-um** `Pessoa`
* `Noticia` **muitos-para-muitos** `Tag`


---

**Migrations**

Como os models foram modificados não se esqueça de executar os comandos `makemigrations` e `migrate`. 

**migrate zero**

Há casos em que você já tem um banco de dados e já executou migrations anteriores, mas não está conseguindo progredir por causa de incompatibilidades que geram erros ou situações que você não consegue resolver no momento. Se você não precisar se importar com perca de dados ou se tiver feito um **backup dos seus dados** pode executar `migrate app_noticias zero` (substituindo `app_noticias` pelo nome do seu app) para desfazer todas as migrations, a depois apagar todos os arquivos de migrations da pasta `migrations` e então executar `makemigrations` novamente. Isso é uma forma de *começar do zero*, por assim dizer (mas use com sabedoria!).

**Voltando no tempo**

Há casos em que você precisa voltar uma migration. Quando precisar fazer isso não apague o arquivo da migration diretamente. O Django controla as migrations executadas no banco de dados, então você precisa fazer isso da forma certa. Se não percebeu ainda, o Django cria as migrations como uma linha do tempo, uma migration dependendo de outra anterior. Depois de criar uma migration, volte para uma migration anterior com o comando `migrate app_name migration_name` (substituindo `app_name` pelo nome do aplicativo e `migration_name` pelo nome da migration -- o nome do arquivo). Depois disso, pode excluir o arquivo da migration desejada.

**migrate app_name** e **makemigrations app_name**

Outra boa prática é, à medida em que o projeto começa a ficar maior, com vários aplicativos, começar a adicionar o nome do aplicativo como parâmetro dos comandos `makemigrations` e `migrate` para diferenciar de outros aplicativos.

---

## Configurando o Django Admin

Para permitir o gerenciamento dos dados cofigure o módulo `app_noticias.admin` para conter o seguinte:

```python
@admin.register(Pessoa)
class PessoaAdmin(admin.ModelAdmin):
    pass


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    prepopulated_fields = {'slug': ('nome',)}


@admin.register(Noticia)
class NoticiaAdmin(admin.ModelAdmin):
    pass
```

Como já foi feito, o padrão é criar uma classe para administrar cada model, herdando de `django.contrib.admin.ModelAdmin` e registrá-la usando `django.contrib.admin.register()`:

* classe que herda de `django.contrib.admin.ModelAdmin`
* usar a função de anotação `register()` passando como argumento o nome do model que será gerenciado pela classe

A classe `TagAdmin` tem uma configuração adicional: `prepopulated_fields` é utilizado para indicar ao Django Admin que um campo deve ser preenchido a partir de outro. Nesse caso, o campo `slug` deve ser preenchido a partir do campo `nome`, mas isso é feito de uma forma diferenciada, por causa do campo do tipo `SlugField`: caracteres especiais e espaços são removidos ou substituídos.

Há mais configurações do Django Admin, mas por enquanto isso já é suficiente para permitir as funcionalidades que são objetivo deste capítulo. Começando pelo cadastro de notícia (como ilustra a [@fig:adicionar-noticia-autor-tags]) agora há um formulário mais completo, com uma interface que permite entrada de dados nos campos e seleção dos registros relacionados.

![Adicionar notícia com autor e tags](./graphics/5-adicionar-noticia.PNG){#fig:adicionar-noticia-autor-tags}

A [@fig:adicionar-noticia-autor-tags] mostra que botões (ícones) ao lado do campo "Autor" permitem acessar as funcionalidades, nesta ordem:

* editar pessoa selecionada (se houver uma pessoa selecionada)
* adicionar/cadastrar pessoa
* excluir pessoa selecionada (se houver uma pessoa selecionada)

Ao clicar no botão "adicionar", por exemplo, aparece uma "popup", uma janela que permite cadastrar a pessoa, como ilustra a [@fig:adicionar-noticia-popup-adicionar-pessoa].

![Adicionar notícia - popup de adicionar pessoa](./graphics/5-adicionar-noticia-popup-adicionar-pessoa.PNG){#fig:adicionar-noticia-popup-adicionar-pessoa}

A [@fig:adicionar-noticia-popup-adicionar-pessoa] mostra que é possível cadastrar a pessoa. Interessante observar que ao salvar os dados o Django Admin fará com que a pessoa seja selecionada como autor na tela de cadastro da notícia (o mesmo vale para a tela de edição).

De forma semelhante, o mesmo acontece com o campo "Tags", embora haja apenas o botão (ícone) para adicionar, permitindo cadastrar uma tag, como ilustra a [@fig:adicionar-noticia-popup-adicionar-tag].

![Adicionar notícia - popup de adicionar tag](./graphics/5-adicionar-noticia-popup-adicionar-tag.PNG){#fig:adicionar-noticia-popup-adicionar-tag}

A [@fig:adicionar-noticia-popup-adicionar-tag] mostra o formulário de cadastro da tag. O comportamento ao salvar é o mesmo observado anteriormente para o cadastro de pessoa: a tag passa a ser parte das tags selecionadas da notícia que está sendo cadastrada. Importante observa que a interface usa um componente de formulário que permite a seleção de múltiplos elementos (há uma descrição na tela sobre como usar a interface para selecionar mais de uma tag ou tirar uma tag da seleção).

Por fim, a [@fig:adicionar-noticia-autor-tags-completo] ilustra o formulário preenchido.

![Adicionar notícia com autor e tags completo](./graphics/5-adicionar-noticia-completo.PNG){#fig:adicionar-noticia-autor-tags-completo}

## Conclusão

Este capítulo apresentou os conceitos de relacionamentos usando os tipos de campos `OneToOneField`, `ForeignKey` e `ManyToManyField`. Além disso, mostrou como o Django Admin adapta a interface de formulários para permitir a seleção de registros relacionados e manter os relacionamentos.
