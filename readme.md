# ZPBCR_EXPORT_IMPORT_TABLE_DATA

O programa ZPBCR_EXPORT_IMPORT_TABLE_DATA é uma ferramenta útil para exportar e importar dados de tabelas do SAP para um arquivo. Isso permite que você faça backup das informações e transporte dados de uma tabela para outro ambiente SAP.

Use o abapgit ([https://abapgit.org]/) para subir essa aplicação para o seu sistema

## Como usar

1. Abra o programa ZPBCR_EXPORT_IMPORT_TABLE_DATA no SAP via SE38.
2. Selecione a tabela que deseja exportar ou importar.
3. Caso queira, indique uma cláusula where e a quantidade de registros a exportar (0 exporta tudo) 
4. Escolha a opção de exportação ou importação e o nome do arquivo.
4. Execute via SE38 ou programe um background job (nesse caso o arquivo deverá ser gravado obrigatóriamente no servidor).

## Screenshot

![Screenshot do programa ZPBCR_EXPORT_IMPORT_TABLE_DATA](https://asabino2.github.io/EXPORT_IMPORT_TABLE.png)