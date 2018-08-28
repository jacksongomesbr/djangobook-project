# Django ORM {#sec:django-orm}

Este capítulo trata de como realizar operações no banco de dados por meio do ORM, como consultas e manipulações dos dados.

## Shell do Django

Aprender a utilizar o ORM do Django é uma tarefa primordial. Pode ser interessante, antes de testes e da programação (desenvolvimento do software, em si) desenvolver a habilidade de lidar com a API do ORM de forma mais direta. Para isso o Django fornece um shell, que pode ser obtido executando o comando:

```{style=nonumber .sh}
python manage.py shell
```

O resultado é um shell interativo (semelhante ao prompt interativo do Python) já carregado com o Django. As seções a seguir podem ser executadas no shell.

## Criando objetos

Para criar um objeto (um registro no banco de dados) há duas formas. A primeira delas é criar uma instância do model e depois chamar o método `save()`, como no exemplo a seguir:

```{style=nonumber .py}
from app_noticia.models import Noticia
n = Noticia(
    titulo='Alta do dólar', 
    conteudo='Dólar sobe para maior preço em dez anos'
)
n.save()
```

A outra forma é chamar o método `create()` de `objects`:

```{style=nonumber .sh}
from app_noticia.models import Noticia
n = Noticia.objects.create(
    titulo='Alta do dólar', 
    conteudo='Dólar sobe para maior preço em dez anos'
)
```

Cada model possui o atributo `objects`, que é chamado de **Manager**, e é muito importante porque dá acesso a opreações de consulta no banco de dados.

Em ambos os casos, tanto para `save()` quanto para `create()`, perceba que os parâmetros são os campos do model -- cuja ordem não é relevante.

Assim que a instância é criada (o registro é salvo no banco de dados) o Django cria automaticamente o atributo `id`, um número inteiro incrementado automaticamente (verifique).

A criação de instâncias funciona de modo semelhante à criação de registros em tabelas com a instrução `INSERT INTO` da linguagem SQL.


## Atualizando objetos

Uma vez que você estiver de posse de uma instância, seus atributos podem ser alterados e, para atualizar o banco de dados, deve ser utilizado o método `save()`. Por exemplo:

```{style=nonumber .sh}
n.conteudo = 'Dólar sobe para maior patamar nos últimos dez anos' 
n.save()
```

O método `save()` precisa ser chamado explicitamente para que o banco de dados seja atualizado, funcionando como a instrução `UPDATE`, em linguagem SQL.


## Recuperando objetos

Para recuperar objetos do banco de dados você utiliza um **Manager** para criar **QuerySet**, que representa uma coleção de objetos do banco de dados. O **Manager** é acessado a partir do atributo de classe `objects`. Exemplo: `Noticia.objects`.

As seções a seguir demonstram as operações mais comuns e consideram o model `Noticia`.

### Recuperar todos os objetos

A maneira mais simples de recuperar todos os objetos de um model é usar o método `all()` do **Manager**:

```{style=nonumber .sh}
todas = Noticia.objects.all()
```

O método `all()` é semelhante à instrução `SELECT * FROM tabela` em linguagem SQL.

Também é possível limitar a quantidade de elementos do `QuerySet` utilizando a sintaxe de **slicing** de array em python:

```{style=nonumber .sh}
primeiras_5 = Noticia.objects.all()[:5]
ultimas_5   = Noticia.objects.all()[5:]
entre_2_e_5 = Noticia.objects.all()[2:5]
```

A sintaxe geral de **slicing** é `OFFSET:LIMIT`, onde: 

* `OFFSET` é a quantidade de registros a deslocar (padrão é zero)
* `LIMIT` é a quantidade de registros a considerar (padrão é a quantidade de registros no `QuerySet`)

portanto (suponha que haja 5 instâncias):

* `:5` significa OFFSET=0, LIMIT=5 (primeiras 5 instâncias)
* `5:` significa OFFSET=5, LIMIT=5 (desloca 5 instâncias, pega 5 instâncias)
* `2:5` significa OFFSET=2, LIMIT=5 (desloca 2 instâncias, pega 5 instâncias)

### Recuperar objetos específicos usando filtros

A maneira mais comum de refinar um **QuerySet** é adicionar filtros. Isso pode ser feito usando os métodos: `filter()` e `exclude()`. Por exemplo: para retornar todas as notícias cujo título seja "Alta do dólar" podemos usar:

```{style=nonumber .sh}
noticias_alta_do_dolar = Noticia.objects.filter(titulo='Alta do dólar')
```

Essa consulta seria semelhante à seguinte em SQL:

```{style=nonumber .sql}
SELECT * FROM Noticia WHERE titulo='Alta do dólar'
```

Para retornar todas as notícias publicadas no ano de 2018 (considerando um campo `data_de_publicacao` do tipo `DateField`):

```{style=nonumber .py}
noticias_alta_do_dolar = Noticia.objects.filter(data_de_publicacao__year=2018)
```

Em SQL, seria semelhante ao seguinte:

```{style=nonumber .sql}
SELECT * FROM Noticia WHERE data_de_publicacao <= '2018-01-01'
```

Os parâmetros de `filter()` e `exclude()` seguem a sintaxe chamada de **Field lookups**.

Também é possível fazer um encadeamento de filtros, como no exemplo:

```{style=nonumber .py}
noticias_nao_dolar_2018 = Noticia.objects.exclude(
    titulo__contains='dólar'
).filter(
    data_de_publicacao__year=2018
)
```

A consulta obtém todas as notícias que não cotêm "dólar" no título e cujo ano da data de publicação seja 2018.

### QuerySets são lazy

O Django não executa uma consulta no banco de dados quando um QuerySet é criado, apenas quando ele é **avaliado**. Veja o exemplo:

```{style=nonumber .py}
noticias_2018 = Noticias.objects.filter(data_de_publicacao__year=2018)
noticias_2018 = noticias_2018.exclude(titulo__contains='dólar')
print(noticias_2018)
```

Apenas na chamada da função `print()` é que a consulta é realizada no banco de dados.

## Recuperar um objeto único 

Como você viu, o método `filter()` é utilizado para retornar um `QuerySet`. Se você deseja retornar um único objeto pode utilizar o método `get()`, que também aceita a mesma sintaxe de **Field lookups**. Por exemplo:

```{style=nonumber .py}
noticia_1 = Noticias.objects.get(id=1)
```

A consulta busca a instância cujo campo `id` seja igual a 1 e seria semelhante à consulta SQL:

```{style=nonumber .sql}
SELECT * FROM Notica WHERE id = 1
```

Quando a consulta não encontra registro o Django dispara uma exceção criada automaticamente para cada model. Por exemplo, se não houver uma instância com `id=1` então será disparada a exceção `Noticia.DoesNotExist`. Por isso, é importante usar o recurso de  tratamento de exceção:

```python
try:
    noticia_1 = Noticias.objects.get(id=1)
    print(noticia_1)
except Noticias.DoesNotExist as erro:
    print('Erro ao tentar encontrar notícia.', erro)
```

## Field lookup

**Field lookup** (que poderíamos traduzir como "expressão de busca") permitem adicionar critérios de busca às consultas e podem ser aplicados aos métodos `get()`, `filter()` e `exclude()`. 

A sintaxe é `campo__pesquisa=valor` onde:

* `campo` é o nome do campo no model
* `pesquisa` é o tipo da pesquisa ou expressão de pesquisa
* `valor` é o valor da expressão de pesquisa

As pesquisas mais comuns são apresentadas na tabela a seguir.

+---------------+---------------------------------------------------------------+
|Pesquisa       | Descrição                                                     |
+---------------+---------------------------------------------------------------+
|`exact`        |Uma comparação exata entre o campo e um valor                  |
+---------------+---------------------------------------------------------------+
|`iexact`       |Uma comparação exata, desconsiderando maiúsculas e minúsculas  |
+---------------+---------------------------------------------------------------+
|`contains`     |Verifica se um campo contém um valor                           |
+---------------+---------------------------------------------------------------+
|`startswith`   |Verifica se um campo começa com um valor                       |
+---------------+---------------------------------------------------------------+
|`endswith`     |Verifica se um campo termina com um valor                      |
+---------------+---------------------------------------------------------------+
|`year`         |Verifica se um campo do tipo `DateField` tem ano igual ao valor|
+---------------+---------------------------------------------------------------+
|`month`        |Verifica se um campo do tipo `DateField` tem mês igual ao valor|
+---------------+---------------------------------------------------------------+
|`lt`           |Verifica se o campo é menor que o valor                        |
+---------------+---------------------------------------------------------------+
|`lte`          |Verifica se o campo é menor ou igual ao valor                  |
+---------------+---------------------------------------------------------------+
|`gt`           |Verifica se o campo é maior que o valor                        |
+---------------+---------------------------------------------------------------+
|`gte`          |Verifica se o campo é maior ou igual ao valor                  | 
+---------------+---------------------------------------------------------------+

## Excluindo objetos

Uma vez que você estiver de posse de uma instância basta utilizar o método `delete()` para excluí-la. Por exemplo:

```{style=nonumber .sh}
n = Noticia.objects.get(id=1)
n.delete()
```

Se precisar, também pode chamar o método `delete()` de um `QuerySet` para excluir várias instâncias ao mesmo tempo. Por exemplo:

```{style=nonumber .sh}
noticias_2018 = Noticia.objects.filter(data_de_publicacao__year=2018)
noticias_2018.delete()
```

O método `delete()` opera de forma semelhante à instrução `DELETE FROM` em linguagem SQL.

