# Melhorando o modelo de dados do Aplicativo Notícias {#sec:melhorando-dados-app-noticias}

Este capítulo mostra como melhorar e evoluir o modelo de dados do aplicativo notícias utilizando recursos do model do Django.

## Relacionamentos

Da mesma forma que bancos de dados relacionais o ORM do Django permite o recurso de relacionamentos entre models e isso pode ser feito de três formas: **muitos-para-um**, **muitos-para-muitos** e **um-para-um**.

### Relacionamentos muitos-para-um 

Para definir um relacionamento **muitos-para-um** use a classe `django.db.models.ForeignKey` ao definir seu model, como faria com outros tipos de campos. Para exemplificar, considere que muitas `Noticia` possam ser escritas por um autor (ou um autor possa escrever muitas notícias) então teríamos um relacionamento **muitos-para-um** entre o model `Pessoa` e `Noticia` (o código a seguir tem apenas os trecho mais importantes para o contexto):

```python
from django.db import models

class Pessoa(models.Model):
    # ...
    pass


class Noticia(models.Model):
    autor = models.ForeignKey(Pessoa, on_delete=models.CASCADE)
    # ...
```

Dessa forma o model `Noticia` tem um campo `autor` que **referencia** o model `Pessoa`. O primeiro parâmetro para o construtor da classe `ForeignKey` é o model relacionado (nesse caso `Pessoa`). A partir daí, os demais parâmetros são nomeados. O parâmetro `on_delete` define o comportamento a ser adotado no caso de uma exclusão do registro relacionado. Ou seja, se a pessoa relacionada for excluída, o que deve ser feita com a notícia da qual ela é autora. Nesse caso o valor `models.CASCADE` instrui o Django a excluir o registro relacionado. Outro valor é `models.SET_NULL`, para atribuir o valor `null` ao campo (nesse caso, o campo precisa aceitar `null` -- com os atributos `null=True` e `blank=True`).


### Relacionamentos muitos-para-muitos

Para definir um relacionamento **muitos-para-muitos** use a classe `django.db.models.ManyToManyFiel` ao definir seu model. Para exemplificar, considere que `Noticia` tem muitas `Tag` e `Tag` tem muitas `Noticia`:

```python
from django.db import models

class Tag(models.Model):
    # ...
    pass


class Noticia(models.Model):
    tags = models.ManyToManyField(Tag)
    # ...
```

