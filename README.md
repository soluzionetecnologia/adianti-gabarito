# adianti-gabarito
Imagem Docker baseado em Ubuntu server 18.04 para desenvolvimento com [Adianti Framework](https://www.adianti.com.br/framework).

A imagem roda Apache/2.4.29 e PHP 7.4.4, bem como todos os módulos e extensões necessárias para a execução do framework. Esse ambiente foi configurado conforme o tutorial [Preparando um servidor gabarito para o Adianti Framework (18.04)](https://www.adianti.com.br/forum/pt/view_4402) escrito por [Pablo Dall'Oglio](http://www.dalloglio.net/).

### Como usar:

1. Instale o [Docker](https://www.docker.com/products/docker-desktop);
2. Execute o comando: $ `docker run -dit -p 80:80 -v /path/of/your/project:/var/www/html soluzionetecnologia/adianti-gabarito`
3. Acesse [http://localhost](http://localhost)

*Substitua `/path/of/your/project` pelo caminho do seu projeto no host.
