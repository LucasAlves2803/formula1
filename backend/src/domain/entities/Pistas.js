const { Model, DataTypes } = require('sequelize');
const sequelize = require('../../infrastructure/database');


class Pistas extends Model {}

Pistas.init({
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    nome: DataTypes.STRING,
    pais_id: DataTypes.INTEGER
    }, {
    sequelize,
    modelName: 'Pistas',
    tableName: 'pistas',
    timestamps: false
    });


module.exports = Pistas;