![Logo da Orange Talents](resources/Orange-Talents-preto-brilhoesombra.png)

# Configurando seu HTTP client com Micronaut para trabalhar com XML em vez de JSON

## Cenário:

Imagine que um desenvolvedor(a) junior do nosso time implementou um HTTP client para consumir uma API REST de um sistema legado, e com base no pouco conhecimento dele(a) sobre Micronaut ele(a) implementou o seguinte código:

```kotlin
@Client("${sistema.terceiro.host}")
interface NovoCarroClient {

    @Post("/api/carros")
    fun criar(@Body request: NovoCarroRequest): NovoCarroResponse

}
```

Embora o código esteja correto ele não funciona como esperado, pois a API REST do sistema legado se comunica usando payloads no formato XML. O desenvolvedor(a) junior não sabe como resolver por falta de experiência no desenvolvimento de APIs REST.

Portanto, como você ajudaria este(a) desenvolvedor(a) com o código da aplicação para fazer essa integração funcionar?

## O que seria bom ver nessa resposta?

- **Peso 6**: Configurar o HTTP client para suportar serialização e deserialização de payloads no formato XML;
- **Peso 3**: Lembrar de adicionar a dependência do Jackson XML no Gradle ou Maven do projeto;
- **Peso 1**: Habilitar os logs do HTTP client do Micronaut e fazer testes com a aplicação;

## Resposta do Especialista:

- Primeiramente conversaria com o desenvolvedor(a) junior para entender o problema de tal forma que ele(a) simulassse o erro para mim. Em seguida tentaria entender o que ele(a) fez com relação ao código para saber até ele(a) onde foi;

- Em seguida, para testar a API e entendê-la em funcionamento eu faria alguns testes com POSTman ou Insomnia enviando payloads no formato XML para ver como a API se comporta e evitar surpresas. Aqui eu faria questão que o desenvolvedor(a) me acompanhasse e entendesse o problema e solução; 

- Após entender a API, eu habilitaria a produção e consumo de payload para trabalhar com formato XML. Para isso, bastaria usar as anotações `@Produces` e `@Consumes` informando o media-type como `application/xml`;

- Adicionaria a dependência do Jackson XML no `build.gradle` do projeto para que o Micronaut consiga serializar e deserializar payloads no formato XML;

- Agora, habilitaria os logs do HTTP client do Micronaut e faria alguns testes com a aplicação no ar para ver se o consumo da API funcionou como esperado. Se houver problema na serialização ou deserialização do XML e DTOs eu recorreria a documentação oficial do Jackson ou Micronaut;

- Por fim, recapitularia tudo com o desenvolvedor(a) para ter certeza que ele(a) entendeu não só a solução em si mas também o problema;