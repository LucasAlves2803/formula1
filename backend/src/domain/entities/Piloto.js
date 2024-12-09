const { Model, DataTypes } = require('sequelize');
const sequelize = require('../../infrastructure/database');

class Piloto extends Model {}

Piloto.init({
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    nome: DataTypes.STRING,
    equipe_id: DataTypes.INTEGER
    }, {
    sequelize,
    modelName: 'Piloto',
    tableName: 'piloto',
    timestamps: false
    });


module.exports = Piloto;
