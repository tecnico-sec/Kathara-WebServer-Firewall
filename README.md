Instituto Superior Técnico, Universidade de Lisboa

**Segurança Informática em Redes e Sistemas**

# Guia de Laboratório - *Nmap*

## Objetivo

O objetivo deste laboratório é aprender as potencialidades do *Nmap* ("Network Mapper"). O *Nmap* é uma ferramenta de código aberto amplamente utilizada para descoberta de máquinas e serviços numa rede. Permite identificar máquinas ativas, portas abertas, serviços em execução e, em muitos casos, obter informação útil sobre versões e sistemas operativos, sendo por isso muito usado em tarefas de administração, diagnóstico e auditoria de segurança.

O laboratório usa uma rede baseada na do laboratório no qual foi configurado um servidor *web* e uma *firewall*. A topologia da rede contém um PC, um servidor *web* e um servidor SQL, todos na mesma LAN, interligados por um *hub* (um *collision domain* do Kathará):

![Topologia de Rede][1]

Como poder inferir da topologia e dos ficheiros de configuração, o endereço da subrede é o 5.5.5.0/24.

Em primeiro lugar, vamos configurar um servidor *web* *Apache* e um servidor de base de dados *SQL* que será usado pelo servidor *web*.
Depois vamos então explorar o comando *Nmap*.


## Exercício 1 -- Configuração de base

1. Inicie o laboratório:

```bash
kathara lstart
```

2. Verifique que no `webserver` o serviço `apache2` está em execução.

```bash
/etc/init.d/apache2 status
```

Se não estiver, execute-o.


----

## Exercício 2 -- *Nmap* básico

Neste exercício vamos usar o *Nmap* para 

1. O posto de trabalho vai ser o `pc1`. Confirme que o *Nmap* está instalado executando:

```bash
nmap --version
```

2. Execute um scan simples à subrede:

```bash
nmap 5.5.5.0/24
```

Quantas máquinas existem na rede e quais os seus endereços IP?

3. Execute um scan apenas para descobrir hosts ativos:

```bash
nmap -sn 5.5.5.0/24
```

4. Execute um scan completo de portas TCP do `webserver`. Em que portos está à escuta o servidor Apache?

```bash
nmap -p- <ip_do_host>
```

5. Execute um scan completo de portas TCP do `sqlserver`. O servidor MariaDB deve estar à escuta no porto TCP/3306. Está?

```bash
nmap -p- <ip_do_host>
```

6. Procure respostas para as seguintes questões:

Qual a diferença entre *open*, *closed* e *filtered*?

Porque alguns portos aparecem como *filtered*?


----

## Exercício 3 -- Descoberta de serviços e sistemas operativos

O *Nmap* pode usar heurísticas para compreender mais sobre as máquinas da rede. Um primeiro caso, é a deteção de serviços, usando o comando `nmap -sV <ip_do_host>`

1. Vamos detectar os serviços do `webserver`. Execute o seguinte comando medindo o tempo aproximado que demora a ser executado:

```bash
nmap -sV <ip_do_host>
```

Repita com o seguinte comando que restringe os portos inspecionados:

```bash
nmap -sV -p 22,80,443 <ip_do_host>
```

Qual a diferença entre o tempo de execução e os resultados obtidos pelos dois comandos?

2. Repita para o `sqlserver`:

```bash
nmap -sV <ip_do_host>
```

O que é que o comando diz sobre o serviço SQL?

3. O *Nmap* também usa heurísticas para detectar o sistema operativo em execução numa máquina. Execute para um dos servidores:

```bash
sudo nmap -O <ip_do_host>
```

O sistema operativo identificado corresponde ao real?




----

## Referências

- *Kathará*, [https://github.com/KatharaFramework/Kathara/wiki][3]

  [1]: media/topologia-de-rede.png
  [2]: https://github.com/KatharaFramework/Kathara-Labs/tree/master/Application%20Level/WebServer
  [3]: https://github.com/KatharaFramework/Kathara/wiki

