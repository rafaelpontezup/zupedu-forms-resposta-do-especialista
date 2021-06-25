![Logo da Orange Talents](resources/Orange-Talents-preto-brilhoesombra.png)

# <titulo>

## Cenário:

...texto...

## O que seria bom ver nessa resposta?

- **Peso 5**: xxxx;
- **Peso 4**: xxxx;
- **Peso 1**: xxxx;

## O que penaliza sua resposta?

- **Penalidade -5**: xxxx;
- **Penalidade -2**: xxxx;

## Resposta do Especialista:

- Eu crio uma classe de controller e implemento o método `create()`...;

- Em seguida anoto a classe com `@Controller` e habilito...;

- Implemento a lógica dentro do método [...]. No fim tenho algo parecido com:
    ```kotlin
    @Entity
    class Carro(
        @field:NotBlank val placa: String, 
        @field:NotBlank @field:Size(max=42) val modelo: String
    ) {

        @Id
        @GeneratedValue
        val id: UUID? = null

    }
    ```

- Por fim, levanto a aplicação e...;