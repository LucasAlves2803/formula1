const { Model, DataTypes } = require('sequelize');
const sequelize = require('../../infrastructure/database');

class PontosPorCorrida extends Model {}

PontosPorCorrida.init({
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    grande_premio_id: DataTypes.INTEGER,
    piloto_id: DataTypes.INTEGER,
    pontos: DataTypes.INTEGER
    }, {
    sequelize,
    modelName: 'PontosPorCorrida',
    tableName: 'pontos_por_corrida',
    timestamps: false
    });


module.exports = PontosPorCorrida;

