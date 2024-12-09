const { Model, DataTypes } = require('sequelize');
const sequelize = require('../../infrastructure/database');

class Equipes extends Model {}

Equipes.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nome: DataTypes.STRING,
  pais_id: DataTypes.INTEGER,
  piloto_ativos: DataTypes.INTEGER
}, {
  sequelize,
  modelName: 'Equipes',
  tableName: 'equipes',
  timestamps: false
});

module.exports = Equipes;