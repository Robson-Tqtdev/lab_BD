# lab_BD
Atividade de banco de dados

🚗Auto Peças Conecta

Sistema de Banco de Dados para gerenciamento de autopeças e serviços mecânicos.

📖 Sobre o projeto

O AutoPeças Conecta é um projeto acadêmico de banco de dados desenvolvido para representar as principais operações de uma empresa de autopeças que também presta serviços mecânicos.
A proposta central é integrar informações de clientes, veículos, peças, estoque, vendas, ordens de serviço, mecânicos e serviços, permitindo maior organização e rastreabilidade das operações.
O banco foi estruturado utilizando o modelo relacional e preparado para implementação no MySQL.

🎯 Problema

Uma empresa de autopeças precisa controlar diversas informações simultaneamente, como:

Quais peças estão disponíveis;
Onde cada peça está armazenada;
Quais veículos são compatíveis com determinada peça;
Quais peças foram vendidas;
Quais peças foram utilizadas em uma ordem de serviço;
Quais serviços foram realizados;
Qual mecânico executou determinado serviço;
Histórico dos atendimentos realizados.

A ausência desse controle pode ocasionar erros de compatibilidade, divergências de estoque, dificuldade na localização das peças e perda do histórico dos atendimentos.

💡 Solução proposta

O AutoPeças Conecta centraliza essas informações em um banco de dados relacional, utilizando relacionamentos, chaves primárias, chaves estrangeiras e restrições de integridade.

O sistema permite controlar:

CLIENTES
   │
   ├── VEÍCULOS
   │
   ├── VENDAS
   │      └── ITENS DA VENDA
   │             └── PEÇAS
   │
   └── ORDENS DE SERVIÇO
          ├── ITENS DA OS
          │      └── PEÇAS
          │
          └── SERVIÇOS
                 └── MECÂNICOS

⚙️ Principais funcionalidades

👤 Clientes

Cadastro de clientes;

Diferenciação entre Pessoa Física e Pessoa Jurídica;
Cadastro de múltiplos telefones;
Cadastro de endereço completo.

🚗 Veículos

Cadastro de veículos;
Associação entre veículo e proprietário;
Associação com modelo do veículo.

🔧 Peças

Cadastro de peças;
Código de barras;
Descrição;
Preço;
Unidade de medida;
Compatibilidade com modelos de veículos.

📦 Estoque

Controle de estoque;
Depósitos;
Prateleiras;
Quantidade disponível;
Localização física das peças.

💰 Vendas

Registro de vendas;
Forma de pagamento;
Itens vendidos;
Quantidade;
Preço unitário;
Total da venda.

🛠️ Ordens de Serviço

Registro de atendimentos;
Veículo atendido;
Peças utilizadas;
Serviços realizados;
Mecânico responsável;
Horas trabalhadas;
Valor cobrado.

🗃️ Estrutura do banco

O modelo lógico possui relações para representar:

Tabela	Finalidade
CLIENTE	Cadastro dos clientes
CLIENTE_PF	Dados específicos de pessoa física
CLIENTE_PJ	Dados específicos de pessoa jurídica
CLIENTE_TELEFONE	Telefones dos clientes
DEPOSITO	Locais de armazenamento
PRATELEIRA	Prateleiras dos depósitos
PECA	Cadastro das peças
ESTOQUE	Quantidade e localização das peças
MODELO_VEICULO	Modelos de veículos
VEICULO	Veículos dos clientes
PECA_MODELO	Compatibilidade entre peças e modelos
ORDEM_SERVICO	Ordens de serviço
ITEM_OS	Peças utilizadas nas OS
MECANICO	Cadastro dos mecânicos
SERVICO	Serviços disponíveis
SERVICO_PRESTADO	Serviços executados
VENDA	Vendas realizadas
ITEM_VENDA	Itens das vendas

🔗 Principais relacionamentos

O projeto possui diferentes tipos de relacionamentos.

Relacionamento N

PEÇA ↔ MODELO_VEICULO

Uma peça pode ser compatível com vários modelos, enquanto um modelo pode utilizar várias peças.

Esse relacionamento é representado pela tabela:

PECA_MODELO

Relacionamento N

ORDEM_SERVICO ↔ PECA

Uma ordem de serviço pode utilizar várias peças e uma peça pode aparecer em várias ordens.

Esse relacionamento é representado por:

ITEM_OS

Relacionamento ternário

O projeto também possui o relacionamento:

ORDEM_SERVICO
       │
       ├──── SERVICO_PRESTADO ──── MECANICO
       │
       └──────── SERVICO

Esse relacionamento permite registrar qual mecânico executou qual serviço em determinada ordem de serviço, além das horas trabalhadas e do valor cobrado.

🧩 Conceitos de modelagem utilizados

O projeto contempla conceitos importantes de Banco de Dados:

Entidades fortes;
Entidade fraca;
Entidades associativas;
Especialização;
Relacionamentos 1;
Relacionamentos N;
Relacionamento ternário;
Atributo composto;
Atributo multivalorado;
Chaves primárias;
Chaves estrangeiras;
Restrições de integridade;
Normalização até a 3FN.

🛠️ Tecnologias utilizadas
MySQL 8.0.16+
SQL
brModelo
Modelo Entidade-Relacionamento
Modelo Relacional

A implementação física utiliza InnoDB, utf8mb4, chaves estrangeiras, CHECK, ENUM e tipos como DECIMAL, VARCHAR, DATETIME e INT AUTO_INCREMENT.

▶️ Como executar

1. Instale o MySQL

É necessário possuir uma versão compatível do MySQL instalada.

2. Crie ou abra o banco

O projeto utiliza o banco:

auto_pecas_db

4. Execute o script SQL

No MySQL Workbench ou outra ferramenta compatível:

SOURCE caminho/do/script.sql;

5. Verifique as tabelas

Após a execução, o banco deverá possuir as tabelas necessárias para o funcionamento do sistema.

O documento do projeto prevê a confirmação da criação do banco auto_pecas_db e das 18 tabelas.

🧪 Testes

Foram previstos testes para verificar:

Criação do banco;
Criação das tabelas;
Consultas de estoque;
Consultas de compatibilidade;
Consultas de vendas;
Consultas de serviços;
Atualização de preços;
Alteração do status de uma OS;
Baixa de estoque;
Bloqueio de quantidades negativas;
Integridade entre cliente e veículo.

📊 Consultas disponíveis

O projeto contempla consultas para:

Listagem de ordens de serviço;
Saldo e localização das peças;
Compatibilidade entre peças e modelos;
Relatório de OS, mecânico e serviço;
Cálculo dos totais das vendas.

📁 Estrutura sugerida do repositório

AutoPecas-Conecta/
│
├── README.md
│
├── banco/
│   └── auto_pecas_conecta.sql
│
├── modelagem/
│   ├── modelo_conceitual.png
│   ├── modelo_logico.png
│   └── modelo_fisico.png
│
├── documentacao/
│   └── Documentacao_Autopecas_Conecta.pdf
│
└── testes/
    └── consultas.sql

👥 Equipe

Isacc Victor
Robson Torquato da Silva
Ricardo Saboia
Pedro Lucas
Thiago Souza Santos

Orientador

Jefferson Salomão

Curso

Engenharia de Software

Disciplina

Laboratório de Banco de Dados

📌 Status do projeto

Concluído para fins acadêmicos.

O modelo foi estruturado para representar as operações principais de uma autopeças com serviços mecânicos, contemplando modelagem conceitual, lógica e física, regras de integridade, dados de teste e consultas.

📚 Documentação

A documentação completa do projeto apresenta o contexto, objetivos, requisitos, modelagem, regras de integridade, normalização, implementação física, testes e conclusão.
