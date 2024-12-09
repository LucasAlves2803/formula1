const { Model, DataTypes } = require('sequelize');
const sequelize = require('../../infrastructure/database');


class GrandePremio extends Model {}

GrandePremio.init({
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    pista_id: DataTypes.INTEGER,
    ano: DataTypes.INTEGER,
    campeao: DataTypes.INTEGER,
    vice: DataTypes.INTEGER,
    terceiro: DataTypes.INTEGER,
    pole_position: DataTypes.INTEGER
    }, {
    sequelize,
    modelName: 'GrandePremio',
    tableName: 'grande_premio',
    timestamps: false
    });

module.exports = GrandePremio;