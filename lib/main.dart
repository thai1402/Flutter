import 'package:flutter/material.dart';
import 'database/app_database.dart';

void main() {
  runApp(const ControleFinanceiroApp());
}

class ControleFinanceiroApp extends StatelessWidget {
  const ControleFinanceiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle Financeiro',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ================= LOGIN =================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> fazerLogin() async {
    final email = emailController.text;
    final senha = senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha e-mail e senha.', Colors.red);
      return;
    }

    final db = await AppDatabase.getDatabase();

    final resultado = await db.query(
      'users',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );

    if (resultado.isEmpty) {
      mostrarMensagem(
        'Usuário não encontrado. Cadastre-se antes de entrar.',
        Colors.red,
      );
      return;
    }

    final usuario = resultado.first;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          userId: usuario['id'] as int,
          nome: usuario['nome'] as String,
        ),
      ),
    );
  }

  void mostrarMensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: cor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FF),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                blurRadius: 15,
                color: Colors.black12,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Controle Financeiro',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: fazerLogin,
                  child: const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CadastroPage(),
                    ),
                  );
                },
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CADASTRO =================

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future<void> cadastrarUsuario() async {
    final nome = nomeController.text;
    final email = emailController.text;
    final senha = senhaController.text;

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      mostrarMensagem('Preencha todos os campos.', Colors.red);
      return;
    }

    final db = await AppDatabase.getDatabase();

    final usuarioExistente = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (usuarioExistente.isNotEmpty) {
      mostrarMensagem('Este e-mail já está cadastrado.', Colors.red);
      return;
    }

    final id = await db.insert('users', {
      'nome': nome,
      'email': email,
      'senha': senha,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardPage(
          userId: id,
          nome: nome,
        ),
      ),
    );
  }

  void mostrarMensagem(String texto, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: cor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FF),
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                blurRadius: 15,
                color: Colors.black12,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_add,
                size: 70,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Criar Conta',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: cadastrarUsuario,
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= DASHBOARD =================

class DashboardPage extends StatefulWidget {
  final int userId;
  final String nome;

  const DashboardPage({
    super.key,
    required this.userId,
    required this.nome,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> transacoes = [];

  @override
  void initState() {
    super.initState();
    carregarTransacoes();
  }

  Future<void> carregarTransacoes() async {
    final db = await AppDatabase.getDatabase();

    final dados = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [widget.userId],
    );

    setState(() {
      transacoes = dados;
    });
  }

  double calcularSaldo() {
    double saldo = 0;

    for (var transacao in transacoes) {
      double valor = transacao['valor'];

      if (transacao['tipo'] == 'Receita') {
        saldo += valor;
      } else {
        saldo -= valor;
      }
    }

    return saldo;
  }

  Future<void> abrirFormularioTransacao() async {
    final tituloController = TextEditingController();
    final valorController = TextEditingController();
    String tipo = 'Receita';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova Transação'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: valorController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Receita',
                        child: Text('Receita'),
                      ),
                      DropdownMenuItem(
                        value: 'Despesa',
                        child: Text('Despesa'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        tipo = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (tituloController.text.isEmpty ||
                        valorController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Preencha título e valor.'),
                        ),
                      );
                      return;
                    }

                    double? valor = double.tryParse(
                      valorController.text.replaceAll(',', '.'),
                    );

                    if (valor == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Digite um valor válido.'),
                        ),
                      );
                      return;
                    }

                    final db = await AppDatabase.getDatabase();

                    await db.insert('transactions', {
                      'titulo': tituloController.text,
                      'valor': valor,
                      'tipo': tipo,
                      'userId': widget.userId,
                    });

                    Navigator.pop(context);
                    carregarTransacoes();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> excluirTransacao(int id) async {
    final db = await AppDatabase.getDatabase();

    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    carregarTransacoes();
  }

  @override
  Widget build(BuildContext context) {
    double saldo = calcularSaldo();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F2FF),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${widget.nome}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Saldo Atual',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'R\$ ${saldo.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: transacoes.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhuma transação cadastrada.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: transacoes.length,
                      itemBuilder: (context, index) {
                        final transacao = transacoes[index];

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              transacao['tipo'] == 'Receita'
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: transacao['tipo'] == 'Receita'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(transacao['titulo']),
                            subtitle: Text(transacao['tipo']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'R\$ ${transacao['valor'].toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: TextStyle(
                                    color: transacao['tipo'] == 'Receita'
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    excluirTransacao(transacao['id']);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: abrirFormularioTransacao,
        child: const Icon(Icons.add),
      ),
    );
  }
}