from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from werkzeug.exceptions import BadRequest, NotFound
from datetime import datetime
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)
# Configuração do banco de dados PostgreSQL
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get(
    'DATABASE_URL', 
    'postgresql://postgres:159159@localhost:5432/receitasnew_db'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Modelo Receita
class Receita(db.Model):
    __tablename__ = 'receitas'
    
    id = db.Column(db.Integer, primary_key=True)
    nome = db.Column(db.String(100), nullable=False)
    ingredientes = db.Column(db.Text, nullable=False)
    modo_preparo = db.Column(db.Text, nullable=False)
    tempo_preparo = db.Column(db.Integer)  # em minutos
    rendimento = db.Column(db.String(50))
    categoria = db.Column(db.String(50))
    data_criacao = db.Column(db.DateTime, default=datetime.utcnow)
    data_atualizacao = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'nome': self.nome,
            'ingredientes': self.ingredientes,
            'modo_preparo': self.modo_preparo,
            'tempo_preparo': self.tempo_preparo,
            'rendimento': self.rendimento,
            'categoria': self.categoria,
            'data_criacao': self.data_criacao.isoformat(),
            'data_atualizacao': self.data_atualizacao.isoformat() if self.data_atualizacao else None
        }

# Rotas da API
@app.route('/receitas', methods=['GET'])
def listar_receitas():
    receitas = Receita.query.all()
    return jsonify([receita.to_dict() for receita in receitas])

@app.route('/receitas/<int:id>', methods=['GET'])
def obter_receita(id):
    receita = Receita.query.get(id)
    if not receita:
        raise NotFound('Receita não encontrada')
    return jsonify(receita.to_dict())

@app.route('/receitas', methods=['POST'])
def criar_receita():
    dados = request.json
    
    # Validação básica
    if not dados or not dados.get('nome') or not dados.get('ingredientes') or not dados.get('modo_preparo'):
        raise BadRequest('Nome, ingredientes e modo_preparo são obrigatórios')
    
    receita = Receita(
        nome=dados['nome'],
        ingredientes=dados['ingredientes'],
        modo_preparo=dados['modo_preparo'],
        tempo_preparo=dados.get('tempo_preparo'),
        rendimento=dados.get('rendimento'),
        categoria=dados.get('categoria')
    )
    
    db.session.add(receita)
    db.session.commit()
    
    return jsonify(receita.to_dict()), 201

@app.route('/receitas/<int:id>', methods=['PUT'])
def atualizar_receita(id):
    receita = Receita.query.get(id)
    if not receita:
        raise NotFound('Receita não encontrada')
    
    dados = request.json
    
    if 'nome' in dados:
        receita.nome = dados['nome']
    if 'ingredientes' in dados:
        receita.ingredientes = dados['ingredientes']
    if 'modo_preparo' in dados:
        receita.modo_preparo = dados['modo_preparo']
    if 'tempo_preparo' in dados:
        receita.tempo_preparo = dados['tempo_preparo']
    if 'rendimento' in dados:
        receita.rendimento = dados['rendimento']
    if 'categoria' in dados:
        receita.categoria = dados['categoria']
    
    db.session.commit()
    
    return jsonify(receita.to_dict())

@app.route('/receitas/<int:id>', methods=['DELETE'])
def deletar_receita(id):
    receita = Receita.query.get(id)
    if not receita:
        raise NotFound('Receita não encontrada')
    
    db.session.delete(receita)
    db.session.commit()
    
    return '', 204

# Tratamento de erros
@app.errorhandler(NotFound)
@app.errorhandler(BadRequest)
def handle_error(e):
    return jsonify({'error': e.description}), e.code

# Comandos CLI para inicialização
@app.cli.command('init-db')
def init_db():
    """Inicializa o banco de dados"""
    db.create_all()
    print('Banco de dados inicializado')

@app.cli.command('seed-db')
def seed_db():
    """Popula o banco de dados com dados de teste"""
    receitas = [
        Receita(
            nome='Bolo de Chocolate',
            ingredientes='- 2 xícaras de farinha\n- 1 xícara de açúcar\n- 3 ovos\n- 200g de chocolate meio amargo',
            modo_preparo='Misture todos os ingredientes e asse por 40 minutos',
            tempo_preparo=60,
            rendimento='8 porções',
            categoria='Sobremesa'
        ),
        Receita(
            nome='Pão de Queijo',
            ingredientes='- 500g de polvilho azedo\n- 250ml de leite\n- 250ml de óleo\n- 2 ovos\n- 200g de queijo meia cura ralado',
            modo_preparo='Misturar os ingredientes e assar em forminhas',
            tempo_preparo=45,
            rendimento='30 unidades',
            categoria='Salgado'
        )
    ]
    
    db.session.bulk_save_objects(receitas)
    db.session.commit()
    print('Banco de dados populado')

if __name__ == '__main__':
    app.run(debug=True)
