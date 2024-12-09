const { Model, DataTypes } = require('sequelize');
const sequelize = require('../../infrastructure/database');

class Pais extends Model {}

Pais.init({
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  nome: DataTypes.STRING
}, {
  sequelize,
  modelName: 'Pais',
  tableName: 'pais',
  timestamps: false
});

module.exports = Pais;