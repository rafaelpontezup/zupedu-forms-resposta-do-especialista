![Logo da Orange Talents](resources/Orange-Talents-preto-brilhoesombra.png)

# Como testar sua API gRPC com Micronaut

## Cenário:

Você acabou de entrar em um time na Zup e foi incubido(a) de parear com um desenvolvedor(a) junior para ajudá-lo(a) a cobrir uma API gRPC com testes automatizados. Essa API será responsável por calcular o frete de entrega a partir de um CEP em um sistema de logística e entrega de produtos ao redor do Brasil. O código da API está de acordo com sua especificação de negócio e foi testado manualmente pelo desenvolvedor(a) ao fim da sua implementação.

O arquivo `.proto` com a especificação da nossa API gRPC é bem simples, afinal trata-se de um microsserviço pequeno e enxuto:

```protobuf
syntax = "proto3";

service FretesGrpcService {

  rpc calcula(FreteRequest) returns (FreteResponse) {}
}

message FreteRequest {
  string cep = 1;
}

message FreteResponse {
  string cep = 1;
  double valor = 2;
}
```

E o código de implementação do endpoint responsável por calcular o frete é este abaixo:

```kotlin
@Singleton
class FretesEndpoint(@Inject val repository: FreteRepository) : FretesGrpcServiceGrpc.FretesGrpcServiceImplBase() {

    override fun calcula(request: FreteRequest, responseObserver: StreamObserver<FreteResponse>) {

        if (request.cep.isNullOrBlank()) {
            responseObserver.onError(Status.INVALID_ARGUMENT
                        .withDescription("CEP não informado")
                        .asRuntimeException())
            return
        }

        if (!request.cep.matches("[0-9]{8}".toRegex())) {
            responseObserver.onError(Status.INVALID_ARGUMENT
                        .withDescription("CEP com formato inválido. Formato esperado: 99999999")
                        .asRuntimeException())
            return
        }

        val frete = repository.findByCep(request.cep)
        if (frete == null) {
            responseObserver.onError(Status.FAILED_PRECONDITION
                        .withDescription("CEP inválido ou não encontrado")
                        .asRuntimeException())
            return
        }

        with(responseObserver) {
            onNext(FreteResponse.newBuilder()
                .setCep(frete.cep)
                .setValor(frete.valor.toDouble())
                .build())
            onCompleted()
        }
    }
}

@Repository
interface FreteRepository : JpaRepository<Frete, Long> {

    fun findByCep(cep: String): Frete?
}

@Entity
class Frete(
    @field:NotBlank
    @field:Pattern(regexp = "[0-9]{8}", message = "CEP com formato inválido")
    @Column(nullable = false, unique = true)
    val cep: String,

    @field:NotNull
    @field:PositiveOrZero
    @Column(nullable = false)
    val valor: BigDecimal = BigDecimal.ZERO
) {

    @Id
    @GeneratedValue
    val id: Long? = null

}
```

Apesar do código estar funcional, a boa prática nesse time é escrever testes automatizados para todo código produzido. Infelizmente o desenvolvedor(a) está tendo seu primeiro contato com escrita de testes automatizados com Micronaut para APIs gRPC. Não à toa você deverá ajudá-lo(a) a cobrir o código acima com testes. Portanto, responda as seguintes questões:

1. Que tipo de teste você escreveria para a classe `FretesEndpoint`: teste de unidade ou teste de integração? E por que?

2. Quantos e quais cenários de testes você enxerga para a classe `FretesEndpoint`?

3. Explique como você implementaria cada cenário de teste que você conseguiu enxergar para a classe `FretesEndpoint`;

## O que seria bom ver nessa resposta?

- **Peso 1**: Demonstrar que entende a importância de **favorecer testes de integração** em vez de testes de unidade para esse tipo de problema (microsserviço com API gRPC), afinal +80% do que esse código faz é integração com rede via gRPC e Protobuf, acesso a banco de dados via JPA/Hibernate e integração com o contexto do Micronaut;
- **Peso 3**: Demonstrar que enxergou no mínimo os **4 cenários** de testes abaixo:
    - calcular o frete para um CEP válido (happy path);
    - não calcular o frete quando CEP for vazio (empty);
    - não calcular o frete quando CEP possuir caracteres não-númericos;
    - não calcular o frete quando CEP for válido mas não existir no banco de dados;
- **Peso 1**: Caso tenha enxergado também o cenário: não calular o frete quando o CEP possuir somente caracteres de espaço em branco (blank);
- **Peso 5**: Demonstrar conhecimento de como escrever testes de integração com Micronaut para uma API gRPC. O importante aqui não é nem o código em si, mas sim demonstrar domínio de como se constrói o teste para cada cenário encontrado, como faz o setup com `@MicronautTest` e principalmente de como se valida os retornos de sucesso e erro de uma API gRPC; 

## O que penaliza sua resposta?

- **Penalidade -2**: Esquecer de desligar o controle transacional do teste via `@MicronautTest(transactional=false)`;
- **Penalidade -5**: Favorecer testes de unidade e mocking em vez de testes de integração com `@MicronautTest`;

## Resposta do Especialista:

1. Teste de integração. Pois o código da API basicamente se integra ao protocolo de comunicação gRPC e ao banco de dados via Micronaut Data. Escrever apenas testes de unidade para esse código ignoraria diversos aspectos importantes desse microsserviço, como:
    - integração com gRPC e Protobuf;
    - setup e integração do contexto do Micronaut;
    - integração com banco de dados via Micronaut Data;
    - mapeamento da entidade `Frete` com JPA/Hibernate;
    - verificação do SQL gerado pela JPA/Hibernate no momento da consulta ao banco de dados;

2. Enxergo 5 cenários de testes descritos abaixo:
    - **happy path**: deve calcular o frete quando o CEP informado for válido e existir no banco de dados;
    - **CEP válido mas não encontrado**: não deve calcular o frete quando o CEP informado for válido mas **não existir** no banco de dados;
    - **CEP vazio (empty)**: não deve calcular o frete quando o CEP informado for **vazio** (lembrando que protobuf não permite atributos nulos);
    - **CEP preenchido com espaços em branco (blank)**: não deve calcular o frete quando o CEP informado possuir **somente espaços em branco**;
    - **CEP preenchido com caracteres não-númericos**: não deve calcular o frete quando o CEP informado possuir algum **caractere não-númerico**;

3. Crio uma classe `FretesEndpointTest` e a anoto com `@MicronautTest` para indicar que se trata de testes de integração, dessa forma o contexto do Micronaut seria startado ao rodar algum método de teste. Também desligo o controle transacional do Micronaut através do `@MicronautTest(transactional=false)` pois o servidor gRPC trabalha numa thread separada e diferente da thread do jUnit, o que ignora a transação aberta em cada método com `@Test` causando efeitos colaterais inesperados na execução da bateria de testes. Ainda dentro da classe de teste, crio uma factory do Micronaut (com `@Factory`) para instanciar e configurar o gRPC client (que aponta para o servidor gRPC embarcado no teste) que será utilizado para consumir o nosso endpoint. Configuro o datasource no arquivo `application-test.yml` para apontar um banco H2 em memoria pois o schema do banco é pequeno e não usa nada especifico de um banco relacional. E para cada cenário de teste citado acima eu implemento algo como:
    - **happy path**: insiro 3 fretes na tabela via `FreteRepository` injetado na classe `FretesEndpointTest`; exercito o endpoint `calcula()` passando um CEP válido existente no banco de dados; e valido se o retorno do endpoint trouxe o CEP informado juntamente com seu valor de frete cadastrado no banco;
    - **CEP válido mas não encontrado**: insiro 3 fretes na tabela via `FreteRepository` injetado na classe `FretesEndpointTest`; exercito o endpoint `calcula()` passando um CEP válido mas não existente no banco de dados; e por fim capturo a exceção `StatusRuntimeException` lançada pelo endpoint para verificar se o status de retorno se trata de um `FAILED_PRECONDITION` com a mensagem de erro `"CEP inválido ou não encontrado"`;
    - **CEP vazio (empty)**: não preciso inserir nada no banco de dados; exercito o endpoint `calcula()` passando um CEP vazio; e por fim capturo a exceção `StatusRuntimeException` lançada pelo endpoint para verificar se o status de retorno se trata de um `INVALID_ARGUMENT` com a mensagem de erro `"CEP não informado"`;
    - **CEP preenchido com espaços em branco (blank)**: não preciso inserir nada no banco de dados; exercito o endpoint `calcula()` passando um CEP com 3 ou 4 espaços em branco; e por fim capturo a exceção `StatusRuntimeException` lançada pelo endpoint para verificar se o status de retorno se trata de um `INVALID_ARGUMENT` com a mensagem de erro `"CEP não informado"`;
    - **CEP preenchido com caracteres não-númericos**: não preciso inserir nada no banco de dados; exercito o endpoint `calcula()` passando um CEP com letras e simbolos; e por fim capturo a exceção `StatusRuntimeException` lançada pelo endpoint para verificar se o status de retorno se trata de um `INVALID_ARGUMENT` com a mensagem de erro `"CEP com formato inválido. Formato esperado: 99999999"`;

