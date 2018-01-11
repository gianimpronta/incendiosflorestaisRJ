# Análise Preditiva de Incêndios Florestais

## Objetivo

Está analise consiste na utilização de observações de queimadas e incêndios florestais feitas pelo INPE 
(Instituto Nacional de Pesquisas Espaciais) em conjunto com observações de estações meteorológicas convencionais do INMET( Instituto Nacional de Meteorologia) na tentativa de obter correlações entre as queimadas e incêndios florestais e as condições meteorológicas de forma a predizer quando ocorrerá um evento.

## Base de dados

Os dados utilizados estão divididos em dois conjuntos:

### __Conjunto de dados: Focos__

Foi utilizada um série temporal extraída do Banco de Dados de queimadas do INPE (<https://prodwww-queimadas.dgi.inpe.br/bdqueimadas>) no formato CSV contendo dados do dia 01/01/2010 até 31/12/2016 com as seguintes colunas:

- DataHora - Data e hora da detecção do foco
- Satelite - Nome do satélite de referência
- Pais - País da detecção
- Estado - estado da detecção
- Municipi - município da detecção
- Bioma - bioma da detecção
- DiaSemCh - A quantos dias a referida área está sem chuvas
- Precipit - Precipitação no momento da detecção
- RiscoFog - Risco de Fogo calculado para a área
- Latitude - Latitude do foco
- Longitud - Longitude do foco
- AreaIndu - Determina se a área do foco é industrial
- FRP - Potência Radiativa do Fogo

O Dataset possui alguns focos duplicados, o que se deve ao fato de vários satélites detectarem o mesmo foco de queimada.
Dimensões do conjunto de dados - 8.618.991 linhas e 13 colunas

### __Conjunto de dados: Meteorologia__

Foram utilizados dados de estações meteorológicas convencionais obtidos através do Banco de Dados Meteorológicos para Ensino e Pesquisa (<http://www.inmet.gov.br/projetos/rede/pesquisa/>) contendo uma série temporal do dia 01/01/2010 ao dia 31/12/2016.

- Estacao – Código da estação convencional
- Data – Data da medição
- Hora – Hora da medição
- TempBulboSeco – temperatura medida com termômetro de bulbo seco
- TempBulboUmido – temperatura medida com termômetro de bulbo úmido
- UmidadeRelativa – umidade relativa do ar
- PressaoAtmEstacao – pressão atmosférica no nível da estação
- VelocidadeVento – velocidade do vento no momento da medição
- Nebulosidade – nebulosidade no momento da medição
- Latitude – Latitude da estação
- Longitude – Longitude da estação

Dimensões do conjunto de dados – 1.781.719 linhas e 11 colunas
