# Formulários e mais sobre templates

Uma das funcionalidades mais importantes de software web é permitir a interação com o usuário por meio da entrada de dados. O HTML fornece o recurso de formulários para entrada de dados e o Django também tem uma maneira específica de tratar esse recurso. 

Embora você já tenha visto o Django Admin tratar entrada de dados de uma forma praticamente automática, não é sempre que será útil ou suficiente disponibilizá-lo para seu usuário. Por exemplo, considere que é necessário fornecer um formulário de contato no `app_noticias`. Não é possível utilizar o Django Admin porque ele requer autenticação e isso é incompatível com essa funcionalide porque ela não deve requerer autenticação: o usuário deve fornecer seu nome, a menagem de contato e, opcionalmente, seu e-mail. 

Este capítulo demonstra como utilizar formulários do Django para implementar essa funcionalidade.

## Model `MensagemDeContato`

O model `MensagemDeContato` possui quatro campos para armazenar: nome, email, mensagem e data do contato: 

```python
class MensagemDeContato(models.Model):
    class Meta:
        verbose_name = 'Mensagem de contato'
        verbose_name_plural = 'Mensagens de contato'

    nome = models.CharField(max_length=128)
    email = models.EmailField('E-mail', null=True, blank=True)
    mensagem = models.TextField()
    data = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nome
```

O campo `email` é de preenchimento opcional. O campo `data`, do tipo `DateTimeField`, tem o parâmetro `auto_now_add=True`, o que faz com que seu valor seja gerado automaticamente no momento em que o registro é criado e não permite que seu valor seja alterado no Django Admin.

## Django Admin

O admin do model `MensagemDeContato` deve ser registrado de forma semelhante aos anteriores:

```python
@admin.register(MensagemDeContato)
class MensagemDeContatoAdmin(admin.ModelAdmin):
    readonly_fields = ('data',)
```

A diferença agora é que o model tem o campo `data`, do tipo `DateTimeField` e que tem o parâmetro `auto_now_add=True`, então o Django Admin não pode editá-lo. Isso torna o campo oculto por padrão (já que o formulário, por padrão, mostra apenas os campos que podem ser editados). Para apresentar o campo em formato apenas para leitura é utilizado o atributo de classe `readonly_fields`.

## Formulários

O Django tem uma mania: as coisas são bem estruturadas. Com formulários não é diferente. Embora você possa fazer tudo em uma view -- esse capítulo não vai seguir por esse caminho -- o Django também permite criar uma estrutura para formulários. Isso significa criar uma classe para representar o formulário de contato com três atributos: nome, email e mensagem. Além disso, a classe é responsável por fazer a validação dos dados. Nesse caso, considere que o aplicativo `app_noticias` não aceita:

* mensagem de contato de e-mail do domínio "gmail.com"
* mensagem de contato que contenha alguma das palavras "problema", "defeito" ou "erro"

A classe `ContatoForm` está em `app_noticias/forms.py`:

```python
from django import forms


class ContatoForm(forms.Form):
    nome = forms.CharField(max_length=128, min_length=12)
    email = forms.EmailField(required=False)
    mensagem = forms.CharField(widget=forms.Textarea)

    def clean(self):
        dados = super().clean()
        # não aceita e-mail do gmail
        email = dados.get('email', None)
        mensagem = dados.get('mensagem')
        if '@gmail.com' in email:
            self.add_error('email', 'Provedor de e-mail não suportado (gmail.com)')
        # testa palavras não permitidas na mensagem
        palavras = ['problema', 'defeito', 'erro']
        for palavra in palavras:
            if palavra in mensagem.lower():
                self.add_error('mensagem', 'Mensagem contém palavra não permitida')
        return dados
```

A classe `ContatoForm` herda de `django.forms.Form` e possui três atributos de classe:

* `nome` do tipo `forms.CharField`
* `email` do tipo `forms.EmailField`
* `mensagem` do tipo `forms.CharField`

Vamos chamar esses atributos de "campos". O campo `nome` tem algumas informações adicionais: aceita de 12 a 128 caracteres, o que é definido, respectivamente, pelos parâmetros nomeados `min_length=12` e `max_length=128`. O campo `email` não é de preenchimento obrigatório (`required=False` -- o valor padrão é `True`). O campo `mensagem` tem um "widget" diferente: `widget=forms.TextArea`. O "widget" é a forma de mudar a aparência do campo.

Além dos atributos a classe sobrescreve o método `clean()`, que é utilizado para implementar a lógica da validação. O método começa obtendo os valores dos campos, por meio da chamada `super().clean()`. A partir de então, utiliza `dados.get()` para obter valores dos campos e tratar cada situação. 

O método `add_error()` é utilizado para adicionar uma mensagem de erro para um campo. O primeiro parâmetro é o nome do campo e o segundo parâmetro é a mensagem de erro. 

Por fim, o método retorna `dados`.

**Muito útil:** Se for necessário gerar um erro não associado a um campo específico pode-se disparar uma exceção `forms.ValidationError`.

É importante observar que a classe `ContatoForm` declara não apenas os campos, mas também a lógica de validação do formulário. Isso é muito útil como arquitetura de software por separar e organizar código de outras partes do software.

## `FormView`

Com o formulário pronto é hora de criar uma view para apresentá-lo. O Django fornece a view `FormView` para apresentar formulários. A seguir, o código que implementa duas classes `ContatoView` e `ContatoSucessoView`:


```python
class ContatoView(FormView):
    template_name = 'app_noticias/contato.html'
    form_class = ContatoForm

    def form_valid(self, form):
        dados = form.clean()
        mensagem = MensagemDeContato(nome=dados['nome'], email=dados['email'], mensagem=dados['mensagem'])
        mensagem.save()
        return super().form_valid(form)

    def get_success_url(self):
        return reverse('contato_sucesso')


class ContatoSucessoView(TemplateView):
    template_name = 'app_noticias/contato_sucesso.html'
```

A classe `ContatoView` é uma `FormView` e, por isso, tem dois atributos de classe:

* `template_name` o nome do template (`app_noticias/contato.html`)
* `form_class` a classe do formulário (`ContatoForm`)

Além disso a classe implementa dois métodos: `form_valid()` e `get_success_url()`. O primeiro é executado quando o formulário está válido, ou seja, quando não há erro de validação. O código obtém os dados do formulário por meio do método `form.clean()`, cria uma instância do model `MensagemDeContato` e chama o método `save()` para salvar no banco de dados. 

Um comportamento padrão de views herdam de `FormView` é entregar uma URL para o browser quando ocorre sucesso na execução do formulário. É por isso que a classe sobrescreve o método `get_success_url()` e seu código usa a função `reverse()` para traduzir o nome da URL `contato_sucesso` em uma URL completa.

A URL `contato_sucesso` está vinculada à view `ContatoSucessoView`, que é uma `TemplateView` bem simples (posso dizer isso agora, sem medo) que apenas apresenta uma tela de confirmação para o usuário.

## Template para o formulário

O template para o formulário (`app_noticias/contato.html`) requer uma estrutura padrão para views que herdam de `FormView`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Contato</title>
    <style type="text/css">
        .errorlist {
            color: red;
        }
    </style>
</head>
<body>
<h1>Contato</h1>
<form method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Enviar mensagem</button>
</form>
</body>
</html>
```

A view `FormVieW` entrega o formulário para o template por meio da variável `form` mas, para apresentar o formulário, é preciso seguir algumas regras. Uma das formas de fazer isso é inserir manualmente o elemento `form`, a tag `csrf_token` (uma tag de segurança do Django), apresentar o formulário utilizando `form.as_p` e, por fim, incluir botões para permitir ao usuário enviar os dados (no exemplo, é utilizado o elemento `button`).

A [@fig:7-app-noticias-contato] mostra o formulario de contato.

![Formulário de contato](./graphics/7-app-noticias-contato.PNG){#fig:7-app-noticias-contato}

A [@fig:7-app-noticias-contato-erro-de-validacao] mostra o formulário de contato com as mensagems de erro.

![Formulário de contato com as mensagens de erro](./graphics/7-app-noticias-contato-erro-de-validacao.PNG){#fig:7-app-noticias-contato-erro-de-validacao}

A [@fig:7-app-noticias-contato-sucesso] mostra a tela de sucesso depois de um preenchimento válido.

![Página de confirmação da mensagem de contato](./graphics/7-app-noticias-contato-sucesso.PNG){#fig:7-app-noticias-contato-sucesso}

Por fim, a [@fig:7-app-noticias-contato-admin] mostra o Django admin apresentando os dados da mensagem de contato.

![Formulário de contato com as mensagens de erro](./graphics/7-app-noticias-contato-admin.PNG){#fig:7-app-noticias-contato-admin}

## Se tem URL de sucesso, tem URL de erro?

É possível que essa pergunta tenha surgido naturalmente nesse ponto: se a `FormView` possui uma `success_url` então também teria algo semelhante a uma `error_url`? A resposta curta é: Não. A resposta longa é: vamos olhar um pouco mais para a filosofia do Django sobre formulários.

A filosofia do Django para formulários é separar código. Isso não funciona apenas para validação, mas também para lógica de negócio. Isso quer dizer que o exemplo que este capítulo apresentou poderia ser feito de outra forma: o código que está no método `form_valid()` da view deveria estar em um método do formulário, que deveria ser chamado em `form_valid()`. Se algo de errado ocorresse, o método deveria disparar uma exceção (usando `forms.ValidationError`), então o browser continuaria na mesma página e seria apresentada uma mensagem de erro. 

Por esse motivo o Django não fornece uma URL de erro.

Há ainda outro recurso para interagir com o usuário para aprensentar mensagens curtas, mas isso será visto em outro capítulo.

## Conclusão

O capítulo apresentou como o Django separa código entre views e formulários. Mostrou também como é a estrutura de uma classe que herda de `Form` para definir campos e a lógica da validação. 

O capítulo também mostrou como a view interage com o formulário e como um formulário é apresentado no template.
