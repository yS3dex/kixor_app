# KIXOR — Gestão de Campeonato de Futebol

Projeto académico de fim de semestre: aplicação Flutter (frontend) ligada
a uma API REST em ASP.NET Core (.NET) com base de dados SQL Server, para
gerir um campeonato de futebol (equipas, jogadores, jogos e classificação).

## Visão geral da arquitetura

```
Flutter (kixor_app)  --HTTP/JSON-->  API ASP.NET Core (APIPROJETO)  --EF Core-->  SQL Server (KixorDB)
```

- **kixor_app/** — app Flutter (Dart), consome a API via `http`.
- **APIPROJETO/** — Web API em C# (.NET) com Entity Framework Core,
  controllers REST e migrations para o SQL Server.

## Estrutura da pasta `lib/` (Flutter)

```
lib/
├── main.dart                          -> entrada da app, configura o Provider e o MaterialApp
├── theme/
│   └── theme.dart                     -> Dark Mode Premium + AppGradients + AppTextStyles
├── constants/
│   ├── app_strings.dart               -> textos fixos da app
│   └── api_config.dart                -> URL base da API (host/porta num só lugar)
├── providers/
│   └── user_session_provider.dart     -> perfil ativo (visitante / treinador / admin) + equipaId
├── models/
│   ├── equipa.dart                    -> equipa + lista de jogadores
│   ├── jogador.dart                   -> jogador (golos/remates ou defesas, conforme posição)
│   ├── jogo.dart                      -> confronto entre duas equipas (placar + data)
│   ├── classificacao.dart             -> linha da tabela de classificação
│   └── utilizador.dart                -> resposta da API de login
├── services/
│   └── campeonato_service.dart        -> todas as chamadas HTTP (CRUD completo)
├── widgets/
│   ├── gradient_button.dart
│   ├── gradient_text.dart
│   └── gradient_border_container.dart
└── screens/
    ├── login/
    │   └── login_screen.dart          -> autenticação real (200/401/403/erro de rede)
    ├── dashboard/
    │   └── dashboard_screen.dart      -> shell com BottomNavigationBar (Painel/Clube/Calendário)
    ├── home/
    │   └── painel_tab.dart            -> último jogo, próximo jogo e jogos da semana
    ├── clube/
    │   ├── clubes_tab.dart            -> lista de clubes + pesquisa
    │   └── clube_detalhe_screen.dart  -> plantel da equipa, adicionar/editar/eliminar jogador
    ├── calendario/
    │   └── calendario_tab.dart        -> cronograma de jogos (passados com placar, futuros agendados)
    └── admin/
        └── admin_home_screen.dart     -> ponto de entrada específico do perfil Admin
```

## Estrutura da API (`APIPROJETO/`)

```
APIPROJETO/
├── Program.cs                  -> configuração (DbContext, CORS, Swagger)
├── appsettings.json             -> connection string do SQL Server (DefaultConnection)
├── Data/
│   └── FutebolContext.cs        -> DbContext (equipas, jogos, jogadores, utilizadores, perfis, classificacao)
├── Models/
│   ├── Equipa.cs
│   ├── Jogador.cs
│   ├── Jogo.cs
│   ├── Utilizador.cs
│   ├── Perfil.cs
│   ├── Classificacao.cs         -> view só de leitura (sem chave própria)
│   └── LoginDTO.cs
├── Controllers/
│   ├── Equipa.cs                -> GET (lista/por id com jogadores), POST, PUT, DELETE
│   ├── JogadorController.cs     -> CRUD completo de jogadores
│   ├── JogoController.cs        -> GET (lista/último), POST, PUT (placar), DELETE
│   ├── UtilizadorController.cs  -> registo + login
│   └── Classificacao.cs         -> GET da tabela de classificação
└── Migrations/                  -> histórico do schema (EF Core)
```

## Como ligar tudo (passo a passo)

### 1. Base de dados
Garante que o SQL Server está a correr localmente e aplica as migrations:
```powershell
dotnet ef database update --project "<caminho>\APIPROJETO\APIPROJETO"
```
(opcional) corre `kixor_seed.sql` no SSMS para popular equipas, treinadores,
jogadores e jogos de exemplo.

### 2. API
Abre `APIPROJETO` no Visual Studio e corre (F5). Por padrão fica disponível em:
```
http://localhost:5132/api
```
Testa em `http://localhost:5132/swagger`.

### 3. Flutter
O endereço da API está centralizado em `lib/constants/api_config.dart`:
```dart
static const String _host = '10.0.2.2'; // emulador Android Studio
static const int _port = 5132;
```
- **Emulador Android (Android Studio):** mantém `10.0.2.2` (aponta para o
  `localhost` da máquina onde a API está a correr).
- **Dispositivo físico:** troca para o IP da rede local do PC (ex.: `192.168.1.215`).

Depois:
```powershell
flutter pub get
flutter run
```

## Perfis e permissões

| Perfil      | id_perfil | Acesso                                                              |
|-------------|-----------|-----------------------------------------------------------------------|
| Admin       | 1         | Tudo: editar placares, adicionar/eliminar jogadores em qualquer clube |
| Treinador   | 2         | Apenas o seu clube (`id_equipa`): adicionar/editar/eliminar jogadores |
| Utilizador / Visitante | 3 / — | Apenas leitura (consulta clubes, calendário e painel)        |

Logins de exemplo (criados pelo `kixor_seed.sql`):
- `admin@kixor.com` / `admin123`
- `brasil@kixor.com` / `brasil123` (treinador do Brasil)
- `portugal@kixor.com` / `portugal123` (treinador de Portugal)
- ...mesmo padrão `<equipa>@kixor.com` / `<equipa>123` para as restantes.

## Fluxo de autenticação

`POST /api/Utilizador/login` com `{ "email": ..., "password": ... }`:
- `200` -> `Utilizador.fromJson`, mapeia `id_perfil` para `UserRole` e
  guarda a sessão no `UserSessionProvider` (com `equipaId` se for treinador).
- `401` -> `CredenciaisInvalidasException`, SnackBar vermelho.
- Timeout / sem rede / formato inesperado -> `ApiException` com mensagem
  amigável, também via SnackBar.

Botão **"Entrar como Visitante"** ignora a API e entra direto em modo leitura.

## Estado atual

- ✅ Login real (Admin / Treinador / Visitante) com permissões aplicadas na UI
- ✅ CRUD de jogadores (nome, camisola, posição; estatísticas começam a 0)
- ✅ CRUD de jogos (placar, agendamento) — edição restrita ao Admin
- ✅ Pesquisa de clubes por nome
- ✅ Calendário distinguindo jogos finalizados (com placar) de agendados
- ✅ Painel com último jogo, próximo jogo e jogos da semana (só os futuros)
