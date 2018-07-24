# Prefácio

Este é um livro sobre tecnologias de desenvolvimento de software para a web com foco no **Django**, um *framework* de desenvolvimento web. Um *framework* representa um modelo, uma forma de resolver um problema. Em termos de desenvolvimento de software para a web um framework fornece ferramentas (ie. código) para o desenvolvimento de aplicações. Geralmente o propósito de um framework é agilizar as atividades de desenvolvimento de software, inclusive, fornecendo código pronto (componentes, bibliotecas etc.) para resolver problemas comuns, como uma interface de cadastro.

O objetivo deste livro é fornecer uma ferramenta para o desenvolvimento de habilidades de desenvolvimento web com Django, com a expectativa de que você comece aprendendo o básico (o "hello world") e conclua com habilidades necessárias para o desenvolvimento de software que conecta com banco de dados ou fornece uma API HTTP REST, por exemplo.

## Convenções

Os trechos de código apresentados no livro seguem o seguinte padrão:

* **comandos**: devem ser executados no prompt; começam com o símbolo `$`
* **códigos-fontes**: trechos de códigos-fontes de arquivos

A seguir, um exemplo de comando:

```{style=nonumber .sh}
$ mkdir hello-world
```

O exemplo indica que o comando `mkdir`, com a opção `hello-world`, deve ser executado no prompt para criar uma pasta com o nome `hello-world`.

A seguir, um exemplo de código-fonte:

```python
class Pessoa:
    pass
```

O exemplo apresenta o código-fonte da classe `Pessoa`. Em algumas situações, trechos de código podem ser omitidos ou serem apresentados de forma incompleta, usando os símbolos `...` e `#`, como no exemplo a seguir:

```python
class Pessoa:
    def __init__(self, nome):
        self.nome = nome
    
    def salvar(self):
        # executa validação dos dados
        ...
        # salva 
        return ModelManager.save(self)
```

## Ambiente de execução do Python e do Django

Este livro é voltado para a versão **3.x** do Python e versão **2.x** do Django. [@sec:apendice-1] apresenta um rápido tutorial sobre configuração de um ambiente Python com **pip** e **virtualenv** ou **pipenv**. Essas ferramentas são fundamentais para a configuração do ambiente de desenvolvimento.

**pip** é um gerenciador de pacotes para o Python [@piphome]. Uma vez que você precise de recursos adicionais, pode instalar pacotes. Por exemplo, o comando a seguir demonstra como instalar o Django:

**virtualenv** é uma ferramenta utilizada para gerenciar ambientes de projeto, isolados entre si e do ambiente global do Python [@virtualenvhome]. Com isso, cada projeto pode ter seus pacotes e versões diferentes.

**pipenv** reúne as funcionalidades do **pip** e do **virtualenv** e é uma alternativa mais moderna para o desenvolvimento de software Python [@pipenvhome].

Este livro não leva em consideração o Sistema Operacional do seu ambiente de desenvolvimento, mas é importante que você se acostume a certos detalhes e a certas ferramentas, como o **prompt** ou **prompt de comando**. 


Além destas ferramentas também são utilizadas:

* **Git**
* **Heroku**

O **Git** é um gerenciador de repositórios com recursos de versionamento de código [@githome]. É uma ferramenta essencial para o gerenciamento de código fonte de qualquer software.

O **Heroku** é um serviço de **PaaS** (de *Platform-as-a-Service*) e fornece um ambiente de execução conforme uma plataforma de programação, como o Python, um tecnologia de banco de dados, como MySQL e PostgreSQL e ainda outros recursos, como cache usando Redis [@herokuhome].

---

**Calma! Não pira!** 

(In)Felizmente você não vai usar todas as tecnologias lendo o conteúdo desse livro. Fica para outra oportunidade.

---

Para utilizar o Heroku você precisa criar uma conta de usuário. Acesse [https://www.heroku.com/](https://www.heroku.com/) e crie uma conta de usuário.

Depois que tiver criado e validado sua conta de usuário instale o **Heroku CLI**, uma ferramenta de linha de comando (prompt) que fornece uma interface de texto para criar e gerenciar aplicativos Heroku. Detalhes da instalação dessa ferramenta não são tratados aqui, mas comece acessando [https://devcenter.heroku.com/articles/heroku-cli](https://devcenter.heroku.com/articles/heroku-cli).

## Servidor web

Um **servidor web** é um programa que fornece um serviço de rede que funciona recebendo e atendendo requisições de clientes. Um **cliente**, por exemplo, é o browser.

Um **cliente** solicita um arquivo ao **servidor web**, que recebe a solicitação, atende a solicitação e retorna uma resposta para o cliente. 

Esse modelo é chamado **cliente-servidor** [@wiki:cliente-servidor] e, na web, utiliza o protocolo **HTTP** (de *Hypertext Transfer Protocol*), que determina as regras da comunicação: 

* como o cliente deve enviar uma solicitação para o servidor
* como o servidor deve interpretar a solicitação
* como o servidor deve enviar uma resposta para o cliente
* como o cliente deve interpretar a resposta do servidor

Para ilustrar esse processo a [@fig:com-cliente-servidor] demonstra a comunicação entre cliente e servidor.


```{#fig:com-cliente-servidor .plantuml caption="Exemplo de comunicação cliente-servidor" format="eps" width=10cm}
@startuml
hide footbox
autonumber "<font color=green><b>(0) "
Cliente -> Cliente: prepara solicitação HTTP
Cliente -> Servidor: GET /index.html
activate Servidor
rnote over Cliente : espera resposta...
Servidor -> Servidor : recebe e interpreta\na solicitação
Servidor -> Servidor: localiza o arquivo em disco
Servidor -> Servidor: prepara resposta HTTP
group 200
	Servidor -> Cliente: <html>...</html>
else 404
    Servidor -> Cliente: Arquivo não encontrado
end
deactivate Servidor
|||
... Restante da comunicação ...
@enduml
```

Como a [@fig:com-cliente-servidor] apresenta, quem inicia a comunicação é o cliente. O servidor recebe a solicitação e retorna uma resposta. A resposta pode ser interpretada como sucesso ou erro. No caso da figura, se o servidor encontrar o arquivo, ele retorna um código de resposta do HTTP com o número 200 e o conteúdo HTML do arquivo `index.html`, caso contrário ele retorna um código de resposta HTTP com o número 404, indicando que o arquivo não foi encontrado.

Como o Django é um framework para desenvolvimento de software esse processo será bastante utilizado e ficará bastante evidente durante seu aprendizado.
