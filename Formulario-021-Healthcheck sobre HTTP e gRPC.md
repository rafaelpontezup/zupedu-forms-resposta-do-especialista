![Logo da Orange Talents](resources/Orange-Talents-preto-brilhoesombra.png)

# Healthcheck sobre HTTP e gRPC com Micronaut

## Cenário:

Seu time acabou de subir para produção um microsserviço que expõe uma API gRPC com Micronaut (Micronaut gRPC Application). Apesar do serviço estar funcionando na perspectiva do usuário (todas as features de negócio estão rodando corretamente), o serviço não está corretamente configurado de acordo com a equipe de infraestrutura. O endpoint de healthcheck da aplicação está desligado e dessa forma a equipe de infraestrutura está tendo problemas para monitorar e detectar se a aplicação está no ar ou não, se ela está pronta para receber requisições ou mesmo aumentar o número de nodes (ou pods) para possibilitar a devida escala horizontal.

Seu tech-lead pediu para que você habilite o healthcheck da aplicação para atender a solicitação da equipe de infraestrutura. A equipe de infra também informou os seguintes detalhes:

- habilitar o healthcheck HTTP da aplicação;
- habilitar os indicadores Liveness e Readiness para Kubernetes;
- o endpoint de health deve ser consumido somente por usuários autenticados;
- os detalhes de indicadores do endpoint devem ser visíveis somente para usuários autenticados;

Portanto, como você faria para habilitar os endpoints de healtcheck da sua aplicação Micronaut seguindo as orientações da equipe de infra?

## O que seria bom ver nessa resposta?

- **Peso 7**: Habilitar o módulo Micronaut Management para expor o endpoint de healthcheck no arquivo `build.gradle`: dependência `io.micronaut:micronaut-management` e servidor HTTP Netty (`runtime "netty"`);
- **Peso 2**: Configurar endpoint de health para permitir somente acesso a usuários logados: `sensitive: true`;
- **Peso 1**: Configurar endpoint de health para exibir detalhes do endpoint somente para usuários autenticados: `details-visible: AUTHENTICATED`;

## Resposta do Especialista:

- Eu verifico se o módulo Micronaut Management está configurado como dependência da aplicação no arquivo de build do Gradle. Caso ele não esteja configurado, eu adiciona a seguinte dependência no arquivo `build.gradle`:
    ```groovy
    implementation("io.micronaut:micronaut-management")
    ```

- Em seguida, por se tratar de uma Micronaut gRPC Application, eu habilito o servidor HTTP Netty no arquivo de build do Gradle, pois o endpoint de healthcheck é exposto através de uma API REST via servidor HTTP. Para isso, eu adiciono a linha no arquivo do Gradle:
     ```groovy
    micronaut {
        runtime "netty"
        // ...
    }
    ```

- Agora, para aplicar as orientações da equipe de infra, eu configuro a aplicação com os detalhes de segurança do endpoint de health. Para isso,  eu adiciona as linhas abaixo no arquivo `application.yml`:
    ```yaml
    endpoints:
        health:
            sensitive: true
            details-visible: AUTHENTICATED
    ```

- Por fim, abro o POSTman ou Insomnia para fazer alguns testes no endpoint de healthcheck e ter certeza que ele foi habilitado corretamente;