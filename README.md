LETI 2020/21 | Segurança Informática em Redes e Sistemas

---

# Guia de Laboratório 5 - NetKit-WebServer-Firewall

## Objectivo

O objectivo do guia consiste em configurar um servidor de web Apache e
uma firewall simples (iptables).


## Introdução

O laboratório esta separado em três partes sequenciais.
Em primeiro lugar, vamos configurar um servidor web apache com o objetivo de 
servir uma pagina web simples.
Em segundo lugar, vamos adicionar um serviço usado por esse servidor web (um servidor de sql).
Por fim, vamos configurar um firewall para mediar o acesso a essa pagina web.

Aconselhamos a ir guardando os comandos que façam alterações que forem fazendo ao laboratório que queiram tornar permanentes no fim dos ficheiros de startup para conseguirem reproduzir rapidamente o trabalho efetuado. Se quiser ter testes as alterações que fez, pode criar pequenos scripts de python/bash com testes e coloca-los na pasta /shared e chama-los a partir do ficheiros de startup.


## Exercício 1 -- Servidor web

O exercício consiste em lançar o servidor de web Apache e configurá-lo, de modo a que, ao nível da aplicação,
coloquemos algumas restrições sobre que ficheiros estão acessíveis.
Este servidor, desenvolvido como um projecto de código aberto, é desde 1996 o mais usado a nível mundial.
Vamos agora executar alguns passos para configurar o apache.

1. Inicie o laboratório:
```bash
kathara lstart
```

2. Verifique que no webserver o serviço apache2 está a correr. 
```bash
/etc/init.d/apache2 status
```

(A pasta /etc/init.d contem os serviços duma máquina linux no modo SysVInit, atualmente será mais 
comum num pc normal utilizar o comando systemctl do modo systemd em vez do SysVInit).

3. No debian10, os URL's disponibilizados pelo apache, mapeiam para ficheiros dentro da pasta `/var/www/html` por definição. Dentro do webserver execute o comando curl para tentar fazer um pedido ao ficheiro `public/index.html`.
```bash
curl -v 'http://localhost/public/index.html'
curl -v 'http://localhost/notpublic/onlymine.jpg'
```

4. Após fazer este pedido, observe como o apache guarda no ficheiro `/var/log/apache2/access.log` informação
relativa ao pedido feito pelo curl.
```bash
tail -n 10 /var/log/apache2/access.log 
```

5. O apache contem diferentes módulos que podem ser opcionalmente ativados para implementar funcionalidades. Um desses módulos é o módulo cgi, que permite executar scripts quando um determinado ficheiro é pedido. Para ativá-lo:
```bash
a2enmod cgi
/etc/init.d/apache2 restart
```
Podemos verificar que o módulo foi ativado verificando que na pasta /etc/apache2/mods-enabled se encontra um ficheiro como nome do modulo (cgi)

6. E possível executar-mos scripts dentro da pasta `/usr/lib/cgi-bin/` como resposta a pedidos http, por exemplo `public/exam_answers.py`:
```bash
curl -v 'http://127.1.2.3/cgi-bin/public/past_exam_answers.py'
```

7. Usando o curl, observe como a partir do pc1 consegue obter as página web `http://<ip do webserver>/public/index.html` e `cgi-bin/public/past_exam_answers.py` como esperado. Observar também que no ficheiro access.log foi registado o acesso pelo ip do pc1. (Ao tentar aceder a `exam_answers.py`, obterá um erro por não estar ligado ao serviço da base de dados, que será corrigido no exercício 2).

9. Observe como a partir do pc1 consegue obter `http://<ip do webserver>/notpublic/onlythis.jpg` e `cgi-bin/public/past_exam_answers.py`, o que não deveria acontecer. Pelo menos conseguimos verificar que estes ficheiros foram acedidos indevidamente no access.log, vamos então corrigir a nossa configuração de modo a que não estejam acessíveis.

10. Vamos então desativar o acesso a esses ficheiros. Para o fazer, o apache permite definir permissões por diretório,  criando um ficheiro '.htaccess' na raiz do diretório que queremos definir permissões. Coloque um ficheiro '.htaccess' com este conteúdo nas pastas notpublic e reinicie o laboratório:
```bash
deny from all
```

11. Volte a executar os pedidos com o curl e observe a resposta do servidor (403 Forbidden).


## Exercício 2 -- Adicionar um serviço usado pelo servidor web.

Agora que temos o servidor de apache configurado, vamos adicionar um novo servidor à nossa rede que terá um serviço a correr na porta 3306 que será usado pelo webserver na página `http://<ip do webserver>/cgi-bin/public/past_exam_answers.py` (este serviço é uma base de dados sql (mariadb)).

Para o fazer-mos, a máquina sqlserver já está pré-configurada com um servidor de sql, apenas temos de ligá-la à rede de modo a que esteja acessível pelo servidor e modificar a segunda linha do ficheiro `exam_answers.py` para ter o ip e porta por onde conseguimos aceder ao sqlserver.

Siga os seguintes passos:

1) Observe a topologia de rede da figura, vamos modificá-la de modo a que o servidor sql fique ligado também a firewall.

![Topologia de Rede][1]

2) Adicione uma regra ao ficheiro webserver.startup de modo a saber para onde encaminhar os pacotes que vão para o pc1.

3) Modifique o ficheiro lab.conf de modo a ligar a máquina `sqlserver` ao switch 'B'.

4) Confirme que o seguinte comando mostra resultados:
```bash
curl `http://<ip do webserver>/cgi-bin/public/past_exam_answers.py`
```

5) Confirme que o seguinte comando não mostra resultados:
```bash
curl `http://<ip do webserver>/cgi-bin/notpublic/future_exam_answers.py`
```
Mas que se executado localmente no webserver funciona:
```bash
python `/usr/lib/cgi-bin/public/future_exam_answers.py`
```

## Exercício 3 -- Firewall

Agora que temos a nossa webapp de perguntas de exames a correr no servidor corretamente, vamos observar o comportamento do ponto de vista de um utilizador. Recorde a topologia de rede que utilizou no exercício 2 e vamos observar o comportamento a partir do pc1.

1. No pc1, verifique que consegue aceder aos exames passados e nao aos futuros, tal como observava no servidor:
```bash
curl `http://<ip do webserver>/cgi-bin/public/past_exam_answers.py`
curl `http://<ip do webserver>/cgi-bin/notpublic/future_exam_answers.py`
```

2. Infelizmente, ainda temos problemas na nossa configuração de rede. Observe o que acontece se executar o seguinte comando no cliente:
```bash
nmap <ip do sqlserver>
```

3. A porta do mariadb (3306) esta acessível ao mundo exterior. Isto tem 2 problemas. Em primeiro lugar e possivel um atacante tentar descobrir a nossa password (especialmente dado que a password e password):
```bash
# a partirdo pc1:
mysql -u root -D sirs -e "SELECT * from exams;" -h 5.5.5.3 -ppassword
```
Em segundo lugar, mesmo sem saber a password, e possível o atacante bombardear a porta com pedidos de tentativas de estabelecimento de ligação que consumam recursos no servidor e impeçam ligações legitimas de serem estabelecidas.

4. Vamos utilizar a firewall para criar-mos regras que forcem a só expor-mos os serviços da rede 5.5.5.0/24 que queremos explicitamente expor para o mundo exterior. Para isso vamos utilizar o comando iptables (no debian10 temos de usar o comando iptables-legacy, porque atualmente o comando iptables não funciona corretamente).

5. Na firewall, execute seguinte comando para listar as regras atuais da firewall:
```
iptables -L
```
Vera que existem 3 tipos de regras (INPUT, FORWARD, OUTPUT), e que não existem regras na firewall atualmente.

6. Caso queira apagar a firewall, pode apagar todas as regras existentes executando:
```
iptables -F
```

7. Vamos começar por adicionar uma regra simples que bloqueia todos os pacotes ICMP (ping's) que tenham como destino a firewall:
```
iptables –A INPUT –p icmp –j DROP
```
(Se o comando falhar, relembra-mos que tem de usar iptables-legacy em vez de iptables)

8. Observe o resultado na firewall (iptables -L) e verifique o resultado de tentar pingar a firewall e o webserver a partir do pc1 e de estabelecer uma ligação tcp (obter uma página do webserver).
```bash
ping 5.5.5.1
ping 5.5.5.2
curl http://5.5.5.2/public/index.html
```

9. Apague a regra de input que adicionou
```bash
iptables –D INPUT –p icmp –j DROP
``` 

10. Repita os passos 7. a 9., trocando INPUT com FORWARD e OUTPUT, de modo a observar o que acontece em cada caso. Certifique-se que entende o que faz cada regra.

11. Se quisermos, também podemos criar regras mais especificas, por exemplo, a seguinte regra bloqueia ligações tcp com destino a porta 23 a qualquer endereço na rede 42.42.0.0/16 provenientes da rede 192.168.2.0/24.
```bash
iptables –A INPUT –p tcp –s 192.168.2.0/24 -d 42.42.0.0/16 –-dport 23 –j DROP
```

12. Vamos agora proteger a rede. Comece por apagar todas as regras que criou na firewall:
```bash
iptables -F
```

13. Crie uma regra de ip tables para bloquear o acesso de qualquer pacote do mundo exterior ao sqlserver.

14. Crie uma regra para bloquear pacotes ICMP do sqlserver para o mundo exterior.

15. Crie uma regra para bloquear redireccionamento de pacotes do mundo exterior para o sqlserver.

16. Crie regras para garantir que no servidor web a única porta onde é possível criar ligações é a 80 (onde esta a correr o http), mas que o redireccionamento de pacotes continua ativo. (Pode testar que noutras portas não é possível criar ligações pondo um serviço à espera de ligações numa porta, por exemplo `nc -l 1314` põe um serviço à espera de ligações na porta 1314 tcp).

17. Liste as regras do firewall.

18. Observe que continua a fazer conseguir pedidos http do pc1 para o webserver, mas que não consegue ligar-se ao sqlserver a partir do pc1.

## Referências

-   Kathara, [https://github.com/KatharaFramework/Kathara/wiki][3]

-   Oskar Andreasson, Iptables Tutorial, version 1.2.2,
    [http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html][4],
    2006

  [1]: media/topologia-de-rede.png
  [2]: https://github.com/KatharaFramework/Kathara-Labs/tree/master/Application%20Level/WebServer
  [3]: https://github.com/KatharaFramework/Kathara/wiki
  [4]: http://www.frozentux.net/iptables-tutorial/iptables-tutorial.html
